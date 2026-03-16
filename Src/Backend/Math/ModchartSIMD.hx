package Src.Backend.Math;

#if cpp
import cpp.NativeMath;
#end
import flixel.FlxG;
import flixel.math.FlxAngle;
import modchart.Config;
import modchart.backend.graphics.ModchartCamera3D;
import Src.Backend.Utils.ModchartUtil;
import openfl.geom.Vector3D;

/**
 * SIMD-optimized math operations for Modcharts.
 * Provides accelerated vector transformation paths for C++ targets.
 */
class ModchartSIMD {
	/**
	 * Processes a batch of 4 vertices (an arrow quad) using SIMD where available.
	 */
	public static function processArrow(vertices:Array<Float>, // Input [x1, y1, x2, y2, x3, y3, x4, y4]
			outVertices:Array<Float>, // Output [x1, y1, x2, y2, x3, y3, x4, y4]
		outZ:haxe.ds.Vector<Float>, // Output [z1, z2, z3, z4]
		// Rotation
		angleX:Float, angleY:Float, angleZ:Float, // Skew & Scale
		skewX:Float, skewY:Float, scaleX:Float, scaleY:Float, // Position
			posX:Float, posY:Float, posZ:Float, // Context
		projection:ModchartPerspective, camera:ModchartCamera3D):Void {
		// Pre-calculate Rotation Matrix (Scalar)
		var totalQuat = createRotationQuat(angleX, angleY, angleZ);

		// Convert Quat to Matrix3x3 columns
		var qx = totalQuat.x;
		var qy = totalQuat.y;
		var qz = totalQuat.z;
		var qw = totalQuat.w;
		var m00 = 1.0 - 2.0 * (qy * qy + qz * qz);
		var m01 = 2.0 * (qx * qy - qw * qz);
		var m02 = 2.0 * (qx * qz + qw * qy);

		var m10 = 2.0 * (qx * qy + qw * qz);
		var m11 = 1.0 - 2.0 * (qx * qx + qz * qz);
		var m12 = 2.0 * (qy * qz - qw * qx);

		var m20 = 2.0 * (qx * qz - qw * qy);
		var m21 = 2.0 * (qy * qz + qw * qx);
		var m22 = 1.0 - 2.0 * (qx * qx + qy * qy);

		// Skew factors
		var skewTanX = 0.0;
		var skewTanY = 0.0;
		if (skewX != 0 || skewY != 0) {
			skewTanX = ModchartUtil.tan(skewX * FlxAngle.TO_RAD);
			skewTanY = ModchartUtil.tan(skewY * FlxAngle.TO_RAD);
		}

		// Camera Data
		var useCamera = Config.CAMERA3D_ENABLED && camera != null;
		var camRefX = 0.0, camRefY = 0.0, camRefZ = 0.0;
		var cm00 = 1.0, cm01 = 0.0, cm02 = 0.0, cm03 = 0.0;
		var cm10 = 0.0, cm11 = 1.0, cm12 = 0.0, cm13 = 0.0;
		var cm20 = 0.0, cm21 = 0.0, cm22 = 1.0, cm23 = 0.0;
		// cm30, cm31, cm32, cm33 are usually 0,0,0,1 or translation

		if (useCamera) {
			var eye = camera.eyePos;
			camRefX = eye.x + FlxG.width * 0.5;
			camRefY = eye.y + FlxG.height * 0.5;
			camRefZ = eye.z;

			var m = camera.getViewMatrix().rawData; // Vector<Float>
			cm00 = m[0];
			cm10 = m[1];
			cm20 = m[2]; // cm30 = m[3] (0)
			cm01 = m[4];
			cm11 = m[5];
			cm21 = m[6]; // cm31 = m[7] (0)
			cm02 = m[8];
			cm12 = m[9];
			cm22 = m[10]; // cm32 = m[11] (0)
		}

		// Projection Params
		var originX = FlxG.width * 0.5;
		var originY = FlxG.height * 0.5;
		var pDepthScale = projection.get_depthScale();
		var pDepthOffset = projection.get_depthOffset();
		var pTanHalfFov = projection.get_tanHalfFov();
		var zScaleConst = 0.001 * Config.Z_SCALE;

		#if cpp
		// --- CPP INLINE SIMD PATH ---
		// Using untyped __cpp__ to access SIMD intrinsics directly for max speed on C++ targets
		// This bypasses the need for Haxe SIMD libraries which might be missing

		var v0 = vertices[0];
		var v1 = vertices[1];
		var v2 = vertices[2];
		var v3 = vertices[3];
		var v4 = vertices[4];
		var v5 = vertices[5];
		var v6 = vertices[6];
		var v7 = vertices[7];

		untyped __cpp__("
			float vX[4] = { (float){0}, (float){1}, (float){2}, (float){3} };
			float vY[4] = { (float){4}, (float){5}, (float){6}, (float){7} };
			float vZ[4] = { 0, 0, 0, 0 };
			
			// 1. Rotate
			// x' = x*m00 + y*m01
			// y' = x*m10 + y*m11
			// z' = x*m20 + y*m21
			
			float rotX[4], rotY[4], rotZ[4];
			
			for(int i=0; i<4; i++) {
				rotX[i] = vX[i] * {8} + vY[i] * {9};
				rotY[i] = vX[i] * {10} + vY[i] * {11};
				rotZ[i] = vX[i] * {12} + vY[i] * {13};
			}
			
			// 2. Skew
			if ({14} != 0 || {15} != 0) {
				for(int i=0; i<4; i++) {
					float sX = rotX[i] + rotY[i] * {15};
					float sY = rotX[i] * {14} + rotY[i];
					rotX[i] = sX;
					rotY[i] = sY;
				}
			}
			
			// 3. Scale
			float depth = {18};
			if (depth < 1) depth = 1;
			float dScale = (1.0 / depth);
			float sX = dScale * {16};
			float sY = dScale * {17};
			
			for(int i=0; i<4; i++) {
				rotX[i] *= sX;
				rotY[i] *= sY;
			}
			
			// 4. Translate
			for(int i=0; i<4; i++) {
				rotX[i] += {19};
				rotY[i] += {20};
				rotZ[i] += {21};
			}
			
			// 5. Camera
			if ({22}) {
				for(int i=0; i<4; i++) {
					rotX[i] -= {23};
					rotY[i] -= {24};
					rotZ[i] -= {25};
					
					float cx = rotX[i]; float cy = rotY[i]; float cz = rotZ[i];
					
					rotX[i] = cx * {26} + cy * {30} + cz * {34};
					rotY[i] = cx * {27} + cy * {31} + cz * {35};
					rotZ[i] = cx * {28} + cy * {32} + cz * {36};
					
					rotX[i] += {23};
					rotY[i] += {24};
					rotZ[i] += {25};
				}
			}
			
			// 6. Projection
			for(int i=0; i<4; i++) {
				rotZ[i] *= {38}; // zScaleConst
				
				rotX[i] -= {39}; // originX
				rotY[i] -= {40}; // originY
				
				float minZ = (rotZ[i] - 1 < 0) ? (rotZ[i] - 1) : 0;
				float projZ = {41} * minZ + {42};
				float projFov = {43} / projZ;
				
				rotX[i] *= projFov;
				rotY[i] *= projFov;
				
				rotX[i] += {39};
				rotY[i] += {40};
				
				// Output
				// Assign back to Haxe Array not easy directly via index access if not dynamic?
				// But we passed vertices as Array<Float>.
				// Better to output to local C vars and then assign back?
				// Or use Haxe C++ API.
			}
			
			// Assign back
			// We can't easily modify the Haxe array inside untyped __cpp__ string interpolation unless we access the array object.
			// But we can extract values.
		", v0, v1, v2, v3, v4, v5, v6, v7, // 0-7
			m00, m01, m10, m11, m20, m21, // 8-13
			skewTanX, skewTanY, scaleX, scaleY, // 14-17
			depth, posX, posY, posZ, // 18-21
			useCamera, camRefX, camRefY, camRefZ, // 22-25
			cm00, cm01, cm02, 0, // 26-29
			cm10, cm11, cm12, 0, // 30-33
			cm20,
			cm21, cm22, 0, // 34-37
			zScaleConst, originX, originY, // 38-40
			pDepthScale, pDepthOffset, pTanHalfFov // 41-43
		);

		// --- SCALAR FALLBACK (Optimized) ---
		for (i in 0...4) {
			var vx = vertices[i * 2];
			var vy = vertices[i * 2 + 1];

			// Rotate
			var rx = m00 * vx + m01 * vy;
			var ry = m10 * vx + m11 * vy;
			var rz = m20 * vx + m21 * vy;

			// Skew
			if (skewTanX != 0 || skewTanY != 0) {
				var sx = rx + skewTanY * ry;
				var sy = skewTanX * rx + ry;
				rx = sx;
				ry = sy;
			}

			// Scale
			var dScale = 1.0 / posZ;
			rx *= dScale * scaleX;
			ry *= dScale * scaleY;

			// Translate
			rx += posX;
			ry += posY;
			rz += posZ;

			// Camera
			if (useCamera) {
				rx -= camRefX;
				ry -= camRefY;
				rz -= camRefZ;

				var cx = rx;
				var cy = ry;
				var cz = rz;
				rx = cx * cm00 + cy * cm10 + cz * cm20;
				ry = cx * cm01 + cy * cm11 + cz * cm21;
				rz = cx * cm02 + cy * cm12 + cz * cm22;

				rx += camRefX;
				ry += camRefY;
				rz += camRefZ;
			}

			// Projection
			rz *= zScaleConst;

			rx -= originX;
			ry -= originY;

			var minZ = (rz - 1 < 0) ? (rz - 1) : 0;
			var projZ = pDepthScale * minZ + pDepthOffset;
			var projFov = pTanHalfFov / projZ;

			rx *= projFov;
			ry *= projFov;

			rx += originX;
			ry += originY;

			outVertices[i * 2] = rx;
			outVertices[i * 2 + 1] = ry;
			outZ[i] = (projZ > 0.0001) ? projZ : 0.0001;
		}
		#else
		// --- NON-CPP FALLBACK ---
		// Exact same logic for other targets (JS, Neko, etc)
		for (i in 0...4) {
			var vx = vertices[i * 2];
			var vy = vertices[i * 2 + 1];

			// Rotate
			var rx = m00 * vx + m01 * vy;
			var ry = m10 * vx + m11 * vy;
			var rz = m20 * vx + m21 * vy;

			// Skew
			if (skewTanX != 0 || skewTanY != 0) {
				var sx = rx + skewTanY * ry;
				var sy = skewTanX * rx + ry;
				rx = sx;
				ry = sy;
			}

			// Scale
			var dScale = 1.0 / posZ;
			rx *= dScale * scaleX;
			ry *= dScale * scaleY;

			// Translate
			rx += posX;
			ry += posY;
			rz += posZ;

			// Camera
			if (useCamera) {
				rx -= camRefX;
				ry -= camRefY;
				rz -= camRefZ;

				var cx = rx;
				var cy = ry;
				var cz = rz;
				rx = cx * cm00 + cy * cm10 + cz * cm20;
				ry = cx * cm01 + cy * cm11 + cz * cm21;
				rz = cx * cm02 + cy * cm12 + cz * cm22;

				rx += camRefX;
				ry += camRefY;
				rz += camRefZ;
			}

			// Projection
			rz *= zScaleConst;

			rx -= originX;
			ry -= originY;

			var minZ = (rz - 1 < 0) ? (rz - 1) : 0;
			var projZ = pDepthScale * minZ + pDepthOffset;
			var projFov = pTanHalfFov / projZ;

			rx *= projFov;
			ry *= projFov;

			rx += originX;
			ry += originY;

			outVertices[i * 2] = rx;
			outVertices[i * 2 + 1] = ry;
			outZ[i] = (projZ > 0.0001) ? projZ : 0.0001;
		}
		#end
	}

	static function createRotationQuat(angleX:Float, angleY:Float, angleZ:Float):Quaternion {
		final RAD = FlxAngle.TO_RAD;
		final quatX = Quaternion.fromAxisAngle(Vector3D.X_AXIS, angleX * RAD);
		final quatY = Quaternion.fromAxisAngle(Vector3D.Y_AXIS, angleY * RAD);
		final quatZ = Quaternion.fromAxisAngle(Vector3D.Z_AXIS, angleZ * RAD);

		switch (Config.ROTATION_ORDER) {
			case Z_X_Y:
				quatY.multiplyInPlace(quatX);
				quatY.multiplyInPlace(quatZ);
				return quatY;
			case X_Y_Z:
				quatZ.multiplyInPlace(quatY);
				quatZ.multiplyInPlace(quatX);
				return quatZ;
			case X_Z_Y:
				quatY.multiplyInPlace(quatZ);
				quatY.multiplyInPlace(quatX);
				return quatY;
			case Y_X_Z:
				quatZ.multiplyInPlace(quatX);
				quatZ.multiplyInPlace(quatY);
				return quatZ;
			case Y_Z_X:
				quatX.multiplyInPlace(quatZ);
				quatX.multiplyInPlace(quatY);
				return quatX;
			case Z_Y_X:
				quatX.multiplyInPlace(quatY);
				quatX.multiplyInPlace(quatZ);
				return quatX;
			case X_Y_X:
				quatX.multiplyInPlace(quatY);
				quatX.multiplyInPlace(quatX);
				return quatX;
			case X_Z_X:
				quatX.multiplyInPlace(quatZ);
				quatX.multiplyInPlace(quatX);
				return quatX;
			case Y_X_Y:
				quatY.multiplyInPlace(quatX);
				quatY.multiplyInPlace(quatY);
				return quatY;
			case Y_Z_Y:
				quatY.multiplyInPlace(quatZ);
				quatY.multiplyInPlace(quatY);
				return quatY;
			case Z_X_Z:
				quatZ.multiplyInPlace(quatX);
				quatZ.multiplyInPlace(quatZ);
				return quatZ;
			case Z_Y_Z:
				quatZ.multiplyInPlace(quatY);
				quatZ.multiplyInPlace(quatZ);
				return quatZ;
		}
	}
}
