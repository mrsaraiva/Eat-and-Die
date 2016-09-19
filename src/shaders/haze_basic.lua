--- Heat haze shader.

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

-- Modules --
local loader = require("src.shaders.corona_shader.loader")

-- Kernel --
local kernel = { language = "glsl", category = "filter", group = "heat", name = "basic" }

kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData = {
	{
		name = "extend",
		default = 5, 
		min = .25,
		max = 250,
		index = 0
	},

	{
		name = "frequency",
		default = 1.3, 
		min = .2,
		max = 8,
		index = 1
	},

	{
		name = "center",
		default = display.contentCenterX, 
		min = 0,
		max = display.contentWidth,
		index = 2
	}
}

kernel.vertex = loader.VertexShader[[
	varying P_UV float v_Extension;
	varying P_UV float v_Fraction;
	varying P_UV float v_Angle;

	P_POSITION vec2 VertexKernel (P_POSITION vec2 position)
	{
		P_POSITION float offset = position.x - CoronaVertexUserData.z; // z = center
		P_POSITION float extend = sign(offset) * CoronaVertexUserData.x; // x = extend

		v_Extension = .5 * extend / (offset + extend);
		v_Fraction = (offset + 2. * extend) / (offset + extend);
		v_Angle = TWO_PI * (CoronaTexCoord.y + CoronaTotalTime) * CoronaVertexUserData.y; // y = frequency

		position.x += extend;

		return position;
	}
]]

kernel.fragment = [[
	varying P_UV float v_Extension;
	varying P_UV float v_Fraction;
	varying P_UV float v_Angle;

	P_COLOR vec4 FragmentKernel (P_UV vec2 uv)
	{
		uv.s *= v_Fraction;
		uv.s += (sin(v_Angle) - 1.) * v_Extension;

		if (abs(uv.s - .5) > .5) return vec4(0.);

		return CoronaColorScale(texture2D(CoronaSampler0, uv));
	}
]]

return kernel