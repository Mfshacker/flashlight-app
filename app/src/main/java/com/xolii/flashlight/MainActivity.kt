package com.xolii.flashlight

import android.Manifest
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {

    private lateinit var flashlightButton: Button
    private lateinit var statusText: TextView

    private lateinit var cameraManager: CameraManager
    private var cameraId: String? = null
    private var flashlightOn = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        flashlightButton = findViewById(R.id.flashlightButton)
        statusText = findViewById(R.id.statusText)

        cameraManager =
            getSystemService(CAMERA_SERVICE) as CameraManager

        findFlashlight()

        flashlightButton.setOnClickListener {
            toggleFlashlight()
        }
    }

    private fun findFlashlight() {

        try {

            for (id in cameraManager.cameraIdList) {

                val characteristics =
                    cameraManager.getCameraCharacteristics(id)

                val hasFlash =
                    characteristics.get(
                        CameraCharacteristics.FLASH_INFO_AVAILABLE
                    ) == true

                if (hasFlash) {
                    cameraId = id
                    break
                }
            }

            if (cameraId == null) {
                flashlightButton.isEnabled = false
                statusText.text = "NO FLASHLIGHT AVAILABLE"
            }

        } catch (e: Exception) {

            flashlightButton.isEnabled = false
            statusText.text = "FLASHLIGHT UNAVAILABLE"
        }
    }

    private fun toggleFlashlight() {

        val id = cameraId ?: return

        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {

            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CAMERA),
                100
            )

            return
        }

        try {

            flashlightOn = !flashlightOn

            cameraManager.setTorchMode(
                id,
                flashlightOn
            )

            updateInterface()

        } catch (e: Exception) {

            flashlightOn = false

            Toast.makeText(
                this,
                "Could not control flashlight",
                Toast.LENGTH_SHORT
            ).show()

            updateInterface()
        }
    }

    private fun updateInterface() {

        if (flashlightOn) {

            statusText.text = "FLASHLIGHT ON"
            flashlightButton.text = "TURN OFF"

        } else {

            statusText.text = "FLASHLIGHT OFF"
            flashlightButton.text = "TURN ON"
        }
    }

    override fun onDestroy() {

        if (flashlightOn && cameraId != null) {

            try {
                cameraManager.setTorchMode(
                    cameraId!!,
                    false
                )
            } catch (_: Exception) {
            }
        }

        super.onDestroy()
    }
}
