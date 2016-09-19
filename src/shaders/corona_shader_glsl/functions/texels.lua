--- Mixins for texels.

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

-- Export the functions.
return {

[[
	P_POSITION vec4 BaryCoords (P_UV vec2 uv)
	{
		P_UV vec4 bc = vec4(1. - uv, uv); // .25 * vec4(1. - (2. * uv - 1.), 1. + (2. * uv + 1.))

		return (bc.xzxz * bc.wwyy).zxyw; // Swizzle to account for Corona path order
	}
]], [[
	P_POSITION vec4 BaryApply (P_UV vec4 bc)
	{
		return (bc.xzxz * bc.wwyy).zxyw;
	}

	P_POSITION vec4 BaryPrep (P_UV vec2 uv)
	{
		return vec4(1. - uv, uv);
	}
]]

}