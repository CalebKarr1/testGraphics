#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

struct CustomLightingData
{
    float3 normalWS;
    float3 albedo;
    float3 viewDirectionWS;
    
    float smoothness;
};

float GetSmoothnessPower(float rawSmoothness)
{
    return exp2(10 * rawSmoothness + 1);

}

#ifndef SHADERGRAPH_PREVIEW
float3 CustomLightHandling(CustomLightingData d, Light light)
{
    float3 radiance = light.color;
    float diffuse = saturate(dot(d.normalWS, light.direction));
    float specularDot = saturate(dot(d.normalWS, normalize(light.direction + d.viewDirectionWS)));

    float specular = pow(specularDot, GetSmoothnessPower(d.smoothness)) * diffuse;
    specularDot * diffuse;
    float3 color = d.albedo * radiance * (diffuse+specular);
    return color;

}
#endif
float3 CalculateCustomLighting(CustomLightingData d)
{
    #ifdef SHADERGRAPH_PREVIEW
        float3 lightDir = float3(0.5, 0.5, 0);
        float intensity = saturate(dot(d.normalWS, lightDir))+pow(saturate(dot(d.normalWS,normalize(d.viewDirectionWS+lightDir))),GetSmoothnessPower(d.smoothness));
        
        return d.albedo * intensity;
    #else

        Light mainLight = GetMainLight();
        float3 color = 0;
    
        color += CustomLightHandling(d, mainLight);
        return color;
    #endif
}

void CalculateCustomLighting_float(float3 Normal, float3 Albedo, float3 ViewDirectoin, float Smoothness, out
float3 Color)
{
    CustomLightingData d;
    d.normalWS = Normal;
    d.albedo = Albedo;
    d.viewDirectionWS = ViewDirectoin;
    d.smoothness = Smoothness;
    Color = CalculateCustomLighting(d);

}

#endif 