@cd..
@del system\RSkeletalMeshEx.u
@system\ucc make ini=../RSkeletalMeshEx/make.ini
@copy system\RSkeletalMeshEx.u RSkeletalMeshEx\release\_ready\RSkeletalMeshEx.u
@copy system\RSkeletalMeshEx.dll RSkeletalMeshEx\release\_ready\RSkeletalMeshEx.dll
@pause