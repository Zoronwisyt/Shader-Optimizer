import Foundation
import Metal

/**
 * ZoronShaderKernels - High-performance Metal Shading Language source code
 * Designed to replace heavy 32-bit float routines with optimized half4 SIMD operations,
 * loop unrolling, and branchless blend algorithms.
 */
public struct ZoronShaderKernels {

    /// Source code for fast half-precision blend modes & separable blur passes
    public static let metalSourceCode: String = """
    #include <metal_stdlib>
    using namespace metal;

    struct VertexIn {
        float4 position [[attribute(0)]];
        float2 texCoords [[attribute(1)]];
    };

    struct VertexOut {
        float4 position [[position]];
        float2 texCoords;
    };

    struct ShaderParams {
        float4 color1;
        float4 color2;
        float4 extraParams;
        float2 resolution;
        float time;
        float intensity;
    };

    // MARK: - Fast Separable Blur (Horizontal & Vertical)
    // Replaces alight_blurW and alight_blurH with optimized 9-tap 16-bit half vector kernel
    fragment half4 zoron_fast_blur_w(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> srcTexture [[texture(0)]],
        sampler texSampler [[sampler(0)]],
        constant ShaderParams &params [[buffer(0)]]
    ) {
        half2 texCoord = half2(in.texCoords);
        half dx = (half)(1.0 / max(params.resolution.x, 1.0f));
        
        // 9-tap separable Gaussian kernel weights
        half4 sum = half4(0.0);
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(-4.0 * dx, 0.0))) * 0.05h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(-3.0 * dx, 0.0))) * 0.09h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(-2.0 * dx, 0.0))) * 0.12h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(-1.0 * dx, 0.0))) * 0.15h;
        sum += srcTexture.sample(texSampler, float2(texCoord)) * 0.18h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2( 1.0 * dx, 0.0))) * 0.15h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2( 2.0 * dx, 0.0))) * 0.12h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2( 3.0 * dx, 0.0))) * 0.09h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2( 4.0 * dx, 0.0))) * 0.05h;
        
        return sum;
    }

    fragment half4 zoron_fast_blur_h(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> srcTexture [[texture(0)]],
        sampler texSampler [[sampler(0)]],
        constant ShaderParams &params [[buffer(0)]]
    ) {
        half2 texCoord = half2(in.texCoords);
        half dy = (half)(1.0 / max(params.resolution.y, 1.0f));
        
        half4 sum = half4(0.0);
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0, -4.0 * dy))) * 0.05h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0, -3.0 * dy))) * 0.09h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0, -2.0 * dy))) * 0.12h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0, -1.0 * dy))) * 0.15h;
        sum += srcTexture.sample(texSampler, float2(texCoord)) * 0.18h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0,  1.0 * dy))) * 0.15h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0,  2.0 * dy))) * 0.12h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0,  3.0 * dy))) * 0.09h;
        sum += srcTexture.sample(texSampler, float2(texCoord + half2(0.0,  4.0 * dy))) * 0.05h;
        
        return sum;
    }

    // MARK: - Branchless Accelerated Blend Modes (Half-precision)
    fragment half4 zoron_multiply_fragment(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> baseTexture [[texture(0)]],
        texture2d<half, access::sample> blendTexture [[texture(1)]],
        sampler texSampler [[sampler(0)]]
    ) {
        half4 base = baseTexture.sample(texSampler, in.texCoords);
        half4 blend = blendTexture.sample(texSampler, in.texCoords);
        half3 res = base.rgb * blend.rgb;
        return half4(mix(base.rgb, res, blend.a), base.a);
    }

    fragment half4 zoron_screen_fragment(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> baseTexture [[texture(0)]],
        texture2d<half, access::sample> blendTexture [[texture(1)]],
        sampler texSampler [[sampler(0)]]
    ) {
        half4 base = baseTexture.sample(texSampler, in.texCoords);
        half4 blend = blendTexture.sample(texSampler, in.texCoords);
        half3 res = 1.0h - (1.0h - base.rgb) * (1.0h - blend.rgb);
        return half4(mix(base.rgb, res, blend.a), base.a);
    }

    fragment half4 zoron_overlay_fragment(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> baseTexture [[texture(0)]],
        texture2d<half, access::sample> blendTexture [[texture(1)]],
        sampler texSampler [[sampler(0)]]
    ) {
        half4 base = baseTexture.sample(texSampler, in.texCoords);
        half4 blend = blendTexture.sample(texSampler, in.texCoords);
        
        half3 lo = 2.0h * base.rgb * blend.rgb;
        half3 hi = 1.0h - 2.0h * (1.0h - base.rgb) * (1.0h - blend.rgb);
        half3 mask = step(half3(0.5h), base.rgb);
        half3 res = mix(lo, hi, mask);
        
        return half4(mix(base.rgb, res, blend.a), base.a);
    }

    // MARK: - Fast Brightness & Contrast
    fragment half4 zoron_effect_brightnessContrast_fragment(
        VertexOut in [[stage_in]],
        texture2d<half, access::sample> srcTexture [[texture(0)]],
        sampler texSampler [[sampler(0)]],
        constant ShaderParams &params [[buffer(0)]]
    ) {
        half4 color = srcTexture.sample(texSampler, in.texCoords);
        half brightness = (half)params.extraParams.x;
        half contrast = (half)params.extraParams.y;
        
        half3 adjusted = fma(color.rgb - 0.5h, contrast, 0.5h) + brightness;
        return half4(saturate(adjusted), color.a);
    }
    """
}
