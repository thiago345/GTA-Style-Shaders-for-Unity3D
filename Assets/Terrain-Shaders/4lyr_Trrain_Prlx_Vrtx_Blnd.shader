Shader "Custom/4lyr_Trrain_Prlx_Vrtx_Blnd" {
Properties {
  _Color ("Main Color", Color) = (1,1,1,1)
  _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
  [PowerSlider(5.0)] _Shininess ("Shininess", Range (0.0, 1)) = 0.5
  _HeightMultiplier("Height Multiplier", Float) = 1.0
  _MainTex ("Color R - Layer 0 (RGB)", 2D) = "grey" {}
  _Parallax ("Height R - Layer 0", Range (0.005, 0.08)) = 0.02
  _ParallaxMap ("Heightmap R - Layer 0", 2D) = "black" {}
  _BumpMap ("Normalmap R - Layer 0", 2D) = "bump" {}
  _MainTex1 ("Color G  - Layer 1 (RGB)", 2D) = "grey" {}
  _Parallax1 ("Height G - Layer 1", Range (0.005, 0.08)) = 0.02
  _ParallaxMap1 ("Heightmap G - Layer 1", 2D) = "black" {}
  _BumpMap1 ("Normalmap G - Layer 1", 2D) = "bump" {}
  _MainTex2 ("Color B (RGB) - Layer 2", 2D) = "grey" {}
  _Parallax2 ("Height B - Layer 2", Range (0.005, 0.08)) = 0.02
  _ParallaxMap2 ("Heightmap B - Layer 2", 2D) = "black" {}
  _BumpMap2 ("Normalmap B - Layer 2", 2D) = "bump" {}
  _MainTex3 ("Color_A - Layer 3 (RGB)", 2D) = "grey" {}
  _Parallax3 ("Height A - Layer 3", Range (0.005, 0.08)) = 0.02
  _ParallaxMap3 ("Heightmap A - Layer 3", 2D) = "black" {}
  _BumpMap3 ("Normalmap A - Layer 3", 2D) = "bump" {}
  }
  
  CGINCLUDE
  sampler2D _MainTex;
  sampler2D _BumpMap;
  sampler2D _ParallaxMap;
  sampler2D _MainTex1;
  sampler2D _ParallaxMap1;
  sampler2D _BumpMap1;
  sampler2D _MainTex2;
  sampler2D _BumpMap2;
  sampler2D _ParallaxMap2;
  sampler2D _MainTex3;
  sampler2D _BumpMap3;
  sampler2D _ParallaxMap3;
  fixed4 _Color;
  float _Parallax;
  float _Parallax1;
  float _Parallax2;
  float _Parallax3;
  half _HeightMultiplier;
  half _Shininess;

  struct Input {
    float4 color : COLOR;
    float2 uv_MainTex;
    float2 uv_BumpMap;
    float2 uv_MainTex1;
    float2 uv_BumpMap1;
    float2 uv_MainTex2;
    float2 uv_BumpMap2;
    float2 uv_MainTex3;
    float2 uv_BumpMap3;
    float3 viewDir;
  };

  void vert (inout appdata_full v)
	{

	}

  void surf (Input IN, inout SurfaceOutput o)
  {
    half h 	= tex2D(_ParallaxMap, IN.uv_BumpMap).w;
    half h1 = tex2D(_ParallaxMap1, IN.uv_BumpMap1).w;
    half h2 = tex2D(_ParallaxMap2, IN.uv_BumpMap2).w;
    half h3 = tex2D(_ParallaxMap3, IN.uv_BumpMap3).w;

    float2 offset = ParallaxOffset (h, _Parallax, IN.viewDir);
    float2 offset1 = ParallaxOffset (h1, _Parallax1, IN.viewDir);
    float2 offset2 = ParallaxOffset (h2, _Parallax2, IN.viewDir);
    float2 offset3 = ParallaxOffset (h3, _Parallax3, IN.viewDir);

    float2 full_offset = offset + offset1 + offset2 + offset3;
    full_offset = full_offset / 3 * _HeightMultiplier;

    IN.uv_MainTex += full_offset;
    IN.uv_BumpMap += full_offset;
    IN.uv_MainTex1 += full_offset;
    IN.uv_BumpMap1 += full_offset;
    IN.uv_MainTex2 += full_offset;
    IN.uv_BumpMap2 += full_offset;
    IN.uv_MainTex3 += full_offset;
    IN.uv_BumpMap3 += full_offset;
                             
    half4 color1 = tex2D(_MainTex, IN.uv_MainTex);
    half4 color2 = tex2D(_MainTex1, IN.uv_MainTex1);
    half4 color3 = tex2D(_MainTex2, IN.uv_MainTex2);
    half4 color4 = tex2D(_MainTex3, IN.uv_BumpMap3);

    fixed3 bump_tex1 =  UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)) +
                        UnpackNormal(tex2D(_BumpMap1, IN.uv_BumpMap1)) +
                        UnpackNormal(tex2D(_BumpMap2, IN.uv_BumpMap2)) +
                        UnpackNormal(tex2D(_BumpMap3, IN.uv_BumpMap3));

    half4 mask = IN.color;
    half3 c = color1.rgb * mask.r;
      c += color2.rgb * mask.g;
      c += color3.rgb * mask.b;
      c += color4.rgb * mask.a;
      c = c / 3;
       
               
    o.Albedo =  c * _Color.rgb;
    o.Gloss = color2.a;
    o.Specular = _Shininess;
    o.Normal = bump_tex1 * 3;
  }
    ENDCG

	SubShader {
    	Tags { "RenderType"="Opaque" }
    	LOD 400

    	CGPROGRAM
    	#pragma surface surf BlinnPhong
    	#pragma target 4.0
    	ENDCG
	}

		SubShader {
    	Tags { "RenderType"="Opaque" }
    	LOD 400

    	CGPROGRAM
    	#pragma surface surf BlinnPhong nodynlightmap
      #pragma target 4.0
    	ENDCG
	}
FallBack "Legacy Shaders/Specular"
}