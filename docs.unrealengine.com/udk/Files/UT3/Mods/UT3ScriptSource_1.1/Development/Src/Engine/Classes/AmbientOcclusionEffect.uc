/**
 * AmbientOcclusionEffect - A screen space ambient occlusion implementation.
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class AmbientOcclusionEffect extends PostProcessEffect
	native;

/** The color that will replace scene color where there is a lot of occlusion. */
var(Color) interp LinearColor OcclusionColor;

/** 
 * Power to apply to the calculated occlusion value. 
 * Higher powers result in more contrast, but will need other factors like OcclusionScale to be tweaked as well. 
 */
var(Color) float OcclusionPower;

/** Scale to apply to the calculated occlusion value. */
var(Color) float OcclusionScale;

/** Bias to apply to the calculated occlusion value. */
var(Color) float OcclusionBias;

/** Minimum occlusion value after all other transforms have been applied. */
var(Color) float MinOcclusion;

/** Distance to check around each pixel for occluders, in world units. */
var(Occlusion) float OcclusionRadius;

/** Attenuation factor that determines how much to weigh in samples based on distance, larger values result in a faster falloff over distance. */
var(Occlusion) float OcclusionAttenuation;

/** 
 * Distance in front of a pixel that an occluder must be to be considered a different object, in world units.  
 * This threshold is used to identify halo regions around nearby objects, for example a first person weapon.
 */
var(Occlusion) float HaloDistanceThreshold;

/** 
 * Occlusion factor to assign to samples determined to be contributing to a halo.  
 * 0 would result in full occlusion for that sample, increasing values map to quadratically decreasing occlusion values.
 */
var(Occlusion) float HaloOcclusion;

enum EAmbientOcclusionQuality
{
	AO_High,
	AO_Medium,
	AO_Low
};

/** 
 * Quality of the ambient occlusion effect.  Low quality gives the best performance and is appropriate for gameplay.  
 * Medium quality smooths noise between frames at a slightly higher performance cost.  High quality uses extra samples to preserve detail.
 */
var(Occlusion) EAmbientOcclusionQuality OcclusionQuality;

/** 
 * Distance at which to start fading out the occlusion factor, in world units. 
 * This is useful for hiding distant artifacts on skyboxes.
 */
var(Occlusion) float OcclusionFadeoutMinDistance;

/** Distance at which the occlusion factor should be fully faded, in world units. */
var(Occlusion) float OcclusionFadeoutMaxDistance;

/** Difference in depth that two pixels must be to be considered an edge, and therefore not blurred across, in world units. */
var(Filter) float EdgeDistanceThreshold;

/** 
 * Scale factor to increase EdgeDistanceThreshold for distant pixels.  
 * A value of .001 would result in EdgeDistanceThreshold being 1 unit larger at a distance of 1000 world units. 
 */
var(Filter) float EdgeDistanceScale;

/** 
 * Distance in world units which should map to the kernel size in screen space.  
 * This is useful to reduce filter kernel size for distant pixels and keep detail, at the cost of leaving more noise in the result.
 */
var(Filter) float FilterDistanceScale;

/** Size of the blur filter, in pixels. */
var(Filter) int FilterSize;

/** 
 * Distance in world units that the history pixel must be from the current pixel in order to consider the history valid. 
 * This is used to discard the history for new pixels exposed by parallax with a nearby occluder.
 * Smaller values will reduce the usefulness of the history since less history values will be used.
 * Larger values will result in occlusion streaking since incorrect history values will be used.
 */
var(History) float HistoryDistanceThreshold;

/** 
 * Time in which the occlusion history should approximately converge.  
 * Longer times (.5s) allow more smoothing between frames and less noise but history streaking is more noticeable.
 */
var(History) float HistoryConvergenceTime;



defaultproperties
{
	bAffectsLightingOnly=TRUE
	SceneDPG = SDPG_World;
	OcclusionColor=(R=0.0,G=0.0,B=0.0,A=1.0)
	OcclusionPower=4.0
	OcclusionScale=20.0
	OcclusionBias=-.3
	MinOcclusion=.05
	OcclusionRadius=40.0
	OcclusionAttenuation=50.0
	HaloDistanceThreshold=70.0
	HaloOcclusion=.02
	OcclusionQuality=AO_Medium
	OcclusionFadeoutMinDistance=40000.0
	OcclusionFadeoutMaxDistance=65000.0
	EdgeDistanceThreshold=40.0
	EdgeDistanceScale=.001
	FilterDistanceScale=10.0
	FilterSize=12
	HistoryDistanceThreshold=20.0
	HistoryConvergenceTime=.5
}