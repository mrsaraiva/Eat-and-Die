--- Some utilities for dealing with sampled functions.
--
-- Any such function is stored as a discrete set of samples, termed **SampleSet** in this
-- module. Each sample has **x** and **y** fields, with **x** being the parameter at which
-- the function was sampled and **y** its result.
--
-- Samples are ordered by increasing **x**. Any parameters not of **number** type must
-- therefore define **__lt** (and possibly **__le**) metamethods. Sample lookup similarly
-- introduces the need for arithmetic metamethods, q.v. @{Lookup} and @{Lookup_01}.
--
-- Apart from storing and retrieving them, the module ignores the **y** values.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local assert = assert
local floor = math.floor
local insert = table.insert
local remove = table.remove

-- Modules --
local range = require("src.shaders.tektite_core.number.range")

-- Cached module references --
local _GetCount_
local _Lookup_

-- Exports --
local M = {}

-- Find the first sample corresponding to a parameter
local function AuxLookup (samples, n, x, start) -- n as argument to unify streamline the initialization assert
	assert(n > 0, "Empty sample set")

	-- Too-low x, or single sample: clamp to first sample.
	if n == 1 or x < samples[1].x then
		return 1, 0, samples[1].x > x

	-- Too-high x: clamp to last sample, but also account for x exactly at end.
	elseif x >= samples[n].x then
		return n - 1, 1, samples[n].x < x

	-- A binary search will now succeed, with x known to be within the interval.
	else
		local lo, hi, i = 1, n, range.ClampIn(start or floor(.5 * n), 1, n)

		while true do
			-- Narrow interval: just do a linear search.
			if hi - lo <= 5 then
				i = lo - 1

				repeat
					i = i + 1
				until x < samples[i + 1].x

				return i

			-- x is in an earlier interval.
			elseif x < samples[i].x then
				hi = i - 1

			-- x is in a later interval.
			elseif x >= samples[i + 1].x then
				lo = i + 1

			-- x found.
			else
				return i
			end

			-- Tighten the search and try again.
			i = floor(.5 * (lo + hi))
		end
	end
end

--- Adds a new sample to the set, if _x_ is new; otherwise, updates its corresponding sample.
-- @tparam SampleSet samples
-- @tparam Param x Parameter to assign.
--
-- If this is not of type **number**, note that an **__eq** metamethod is not necessary to
-- establish _x_'s uniqueness.
-- @param y Value to assign.
-- @int[opt] start As per @{Lookup}.
function M.AddSample (samples, x, y, start)
	local n, entry, at = _GetCount_(samples)

	-- Append...
	if n == 0 or x > samples[n].x then
		at = n + 1

	-- ...prepend...
	elseif x < samples[1].x then
		at = 1

	-- ...otherwise, insert or update inside the set.
	else
		local bin, frac = AuxLookup(samples, n, x, start)

		-- Matches left side...
		if frac == 0 then
			entry = samples[bin]

		-- ...or right side...
		elseif bin == n - 1 and frac == 1 then
			entry = samples[bin + 1]

		-- ...otherwise, within bin.
		else
			at = bin + 1
		end
	end

	-- If a new entry is being added, try to recycle an old one. In any case, insert it.
	if at then
		entry, samples.n = remove(samples, n + 1) or {}, n + 1

		insert(samples, at, entry)
	end

	-- Assign the fields. Postponing this until now simplifies some lookups above.
	entry.x, entry.y = x, y
end

--- Accessor.
-- @tparam SampleSet samples
-- @treturn uint Sample count.
function M.GetCount (samples)
	return assert(samples.n, "Uninitialized sampling state")
end

--- Prepares a table for use by the rest of the routines in this module, i.e. afterward
-- _samples_ will be a valid **SampleSet**.
--
-- If _samples_ is already a **SampleSet**, it will be reset.
-- @tparam[opt] ?|table|SampleSet samples Set to prepare. If absent, a table is created.
-- @treturn SampleSet _samples_.
function M.Init (samples)
	samples = samples or {}

	samples.n = 0

	return samples
end

-- Given a parameter, gather information about the bin comprising its corresponding samples
local function FindBin (samples, x, start)
	local n = _GetCount_(samples)
	local i, frac, oob = AuxLookup(samples, n, x, start)

	return i, frac, oob and (frac == 0 and "<" or ">"), samples[i], i < n and samples[i + 1] -- account for one-sample case
end

-- Find where a parameter lies within a bin
local function GetFraction (x, entry, next)
	local x1 = entry.x

	return next and (x - x1) / (next.x - x1) or 0
end

--- Resolves a parameter to a pair of samples.
-- @tparam SampleSet samples Sample set to search.
-- @ptable result A parameter is resolved to two consecutive samples _s1_ and _s2_ (when only
-- one sample is available, it is duplicated). These are used to populate the table.
--
-- Fields **x** and **y** from _s1_ are assigned to _result_'s **x1** and **y1** fields;
-- **x2** and **y2** are similarly populated from _s2_.
--
-- The **bin** field is set to the sample pair's index. For instance, bin #_i_ corresponds
-- to samples #_i_ and #_i_ + 1; a set with _n_ samples has _n_ - 1 bins. The **frac** field,
-- meanwhile, is a number &isin; [0, 1], describing _x_'s relative position in the bin.
-- It is computed as `(x - s1.x) / (s2.x - s1.x)`.
--
-- If _x_ is less than the first sample's **x**, **bin** and **frac** are clamped to 1 and 0,
-- respectively. If _x_ is greater than the last sample's **x**, they are clamped to _n_ - 1
-- and 1, respectively. In the first case, the **out\_of\_bounds** field is set to **"<"**,
-- in the second to **">"**, and otherwise **false**.
-- @tparam Param x Parameter to resolve.
-- @int[opt] start If provided, the index of a sample / bin. If possible, search begins at
-- this position. This might improve search speed if the correct bin is nearby.
function M.Lookup (samples, result, x, start)
	local bin, frac, oob, entry, next = FindBin(samples, x, start)

	result.bin, result.frac = bin, frac or GetFraction(x, entry, next)
	result.out_of_bounds = oob or false

	next = next or entry -- account for one-sample case

	result.x1, result.y1 = entry.x, entry.y
	result.x2, result.y2 = next.x, next.y
end

--- Variant of @{Lookup} parametrized over a unit interval.
-- @tparam SampleSet samples Sample set to search.
-- @ptable result As per @{Lookup}.
-- @tparam Param x As per @{Lookup}, but the parameter space is remapped to [0, 1]. In
-- particular, an _x_ of 0 or 1 corresponds to the first or last sample, respectively.
--
-- The **x1** and **x2** in _result_ will have their regular values.
--
-- Values are remapped as `x = first + (last - first) * x`, where _first_ and _last_ are the
-- **x** values in the first and last sample.
-- @int[opt] start As per @{Lookup}.
function M.Lookup_01 (samples, result, x, start)
	local last = samples[_GetCount_(samples)]

	if last then -- If samples are empty, defer assert to lookup step
		local x1 = samples[1].x

		x = x1 + (last.x - x1) * x
	end

	_Lookup_(samples, result, x, start) 
end

--- Finds the samples parametrized by _x_, failing if _x_ is out-of-bounds.
-- @tparam SampleSet samples Sample set to search.
-- @tparam Param x Parameter to resolve.
-- @int[opt] start As per @{Lookup}.
-- @treturn ?|uint|boolean If _x_ was out-of-bounds, **false**. Otherwise, the index _i_ of
-- the bin belonging to samples #_i_ and #_i_ + 1.
-- @treturn ?number If _x_ was within bounds, its relative position in its bin, as per
-- _result_'s **frac** field in @{Lookup}.
function M.ToBin (samples, x, start)
	local i, frac, oob, entry, next = FindBin(samples, x, start)

	if oob then
		return false
	else
		return i, frac or GetFraction(x, entry, next)
	end
end

--- Variant of @{ToBin} that clamps out-of-bounds parameters.
--
-- In effect, this is a more minimalist version of @{Lookup}.
-- @tparam SampleSet samples Sample set to search.
-- @tparam Param x Parameter to resolve.
-- @int[opt] start As per @{Lookup}.
-- @treturn uint As per _result_'s **bin** field, in @{Lookup}...
-- @treturn number ...and **frac**...
-- @treturn ?|string|boolean ...and **out\_of\_bounds**.
function M.ToBin_Clamped (samples, x, start)
	local i, frac, oob, entry, next = FindBin(samples, x, start)

	return i, frac or GetFraction(x, entry, next), oob
end

--- Updates the **x** and **y** values of an existing sample.
-- @tparam SampleSet samples
-- @uint index Sample index, &isin; [1, _n_], where _n_ is the sample count, cf. @{GetCount}.
-- @tparam Param x Parameter to assign.
--
-- A sample can be updated if `samples[index - 1].x < x and x < samples[index + 1].x` is
-- true. In this context, _samples_[0] and _samples_[_n_ + 1] can be interpreted to have
-- values -&inf; and +&inf;, respectively.
-- @param y Value to assign.
-- @treturn boolean Could the sample be updated?
-- @treturn ?Param If the sample was updated, its previous **x** value...
-- @return ...and **y** value.
-- @see AddSample
function M.UpdateSample (samples, index, x, y)
	local n = _GetCount_(samples)
	local entry = index <= n and samples[index]

	if entry and (index == 1 or x > samples[index - 1].x) and (index == n or x < samples[index + 1].x) then
		entry.x, entry.y, x, y = x, y, entry.x, entry.y

		return true, x, y
	else
		return false
	end
end

-- Cache module members.
_GetCount_ = M.GetCount
_Lookup_ = M.Lookup

-- Export the module.
return M