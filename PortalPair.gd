extends Node

var _portalA : TeleportTestPlane
var _portalB : TeleportTestPlane
var _cameraA : Camera
var _cameraB : Camera



func _ready():
	findPortals()

func findPortals():
	_portalA = $PortalA as TeleportTestPlane
	_portalB = $PortalB as TeleportTestPlane
	
	_cameraA = $PortalA/Plane/PortalA_VP/Camera
	_cameraB = $PortalB/Plane/PortalB_VP/Camera

	_portalA._exit_portal = _portalB
	_portalB._exit_portal = _portalA
	

func UpdateCamera(camera):
	var position = camera.global_transform.origin
	var camera_transform = camera.global_transform
	var planeA_pos = _portalA.to_local(position)
	var planeB_pos = _portalB.to_local(position)
	
	var one_eighty_rotation = Quat(Vector3(0,1,0), PI)
	var portalA_global_transform = _portalA.global_transform
	var portalB_global_transform = _portalB.global_transform
	
	_cameraA.transform.basis = portalB_global_transform.basis * portalA_global_transform.basis.inverse()* Basis(one_eighty_rotation) * camera_transform.basis
	_cameraB.transform.basis = portalA_global_transform.basis * Basis(one_eighty_rotation) * portalB_global_transform.basis.inverse() * camera_transform.basis
	_cameraA.translation = _portalB.to_global( planeA_pos)
	_cameraB.translation = _portalA.to_global(planeB_pos)

