--- Numerical options that require special care, e.g. see [The Right Way to Calculate Stuff](http://www.plunk.org/~hatch/rightway.php).

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
local asin = math.asin
local pi = math.pi
local sin = math.sin

-- Cached module references --
local _SinOverX_

-- Exports --
local M = {}

-- TODO: Specialize for complex numbers, vectors?

--- DOCME
function M.AngleBetween (dot, len, sub)
	return function(a, b, out)
		local neg = dot(a, b) < 0

		out = out or a

		sub(out, b, a)

		local angle = 2 * asin(len(out) / 2)

		return neg and pi - angle or angle
	end
end

--- DOCME
function M.SinOverX (x)
	return 1 + x^2 == 1 and 1 or sin(x) / x
end

--- DOCME
function M.SlerpCoeffs (t, theta)
	local denom, s = _SinOverX_(theta), 1 - t

	return _SinOverX_(s * theta) * s / denom, _SinOverX_(t * theta) * t / denom
end

-- Cache module members.
_SinOverX_ = M.SinOverX

-- Export the module.
return M