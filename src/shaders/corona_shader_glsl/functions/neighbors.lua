--- Neighboring pixel mixins.

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
	P_UV float GetLaplacian (sampler2D s, P_UV vec2 uv, P_UV float a0, P_UV float thickness)
	{
		a0 *= 4.;
		a0 -= texture2D(s, uv + vec2(thickness * CoronaTexelSize.x, 0.)).a;
		a0 -= texture2D(s, uv - vec2(thickness * CoronaTexelSize.x, 0.)).a;
		a0 -= texture2D(s, uv + vec2(0., thickness * CoronaTexelSize.y)).a;
		a0 -= texture2D(s, uv - vec2(0., thickness * CoronaTexelSize.y)).a;

		return a0;
	}
]], [[
	P_UV vec4 GetAbovePixel (sampler2D s, P_UV vec2 uv)
	{
		return texture2D(s, uv + vec2(0., CoronaTexelSize.y));
	}

	P_UV vec4 GetRightPixel (sampler2D s, P_UV vec2 uv)
	{
		return texture2D(s, uv + vec2(CoronaTexelSize.x, 0.));
	}
]]

}