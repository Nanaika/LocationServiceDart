package com.tsdev.location_tracker

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel




import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.IBinder
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices



import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {


//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//
//        // Запускаем службу местоположения
//        val intent = Intent(this, LocationService::class.java)
//        startForegroundService(intent) // Используйте startForegroundService для Android 8.0 и выше
//    }




}



//class LocationService : Service() {
//    private lateinit var fusedLocationClient: FusedLocationProviderClient
//    private lateinit var locationCallback: LocationCallback
//
//    companion object {
//        const val CHANNEL_ID = "ForegroundServiceChannel"
//    }
//
//    override fun onCreate() {
//        super.onCreate()
//        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
//
//        // Создание вызова для получения обновлений местоположения
//        locationCallback = object : LocationCallback() {
//            override fun onLocationResult(locationResult: LocationResult) {
//                val location: Location? = locationResult.lastLocation
//                if (location != null) {
//                    // Отправьте данные о местоположении в ваш Flutter-приложение
//                    // ...
//                }
//            }
//        }
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//        startForegroundService() // Запускаем службу как foreground
//
//        // Запрос обновлений местоположения
//        val locationRequest = LocationRequest.create().apply {
//            interval = 1000
//            fastestInterval = 1000
//            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
//        }
//
//        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
//
//        return START_NOT_STICKY
//    }
//
//    private fun startForegroundService() {
//        createNotificationChannel() // Создайте канал уведомлений
//
//        val notificationIntent = Intent(this, MainActivity::class.java)
//        val pendingIntent: PendingIntent = PendingIntent.getActivity(
//            this,
//            0,
//            notificationIntent,
//            PendingIntent.FLAG_IMMUTABLE // Для Android 12+
//        )
//
//        // Создание уведомления
//        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
//            .setContentTitle("Location Service")
//            .setContentText("Tracking your location...")
//            .setSmallIcon(R.drawable.launch_background) // Проверьте наличие иконки
//            .setContentIntent(pendingIntent)
//            .setPriority(NotificationCompat.PRIORITY_DEFAULT) // Установите приоритет
//            .build()
//
//        startForeground(1, notification) // Запускаем службу как foreground
//    }
//
//    @RequiresApi(Build.VERSION_CODES.O)
//    private fun createNotificationChannel() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                CHANNEL_ID,
//                "Foreground Service Channel",
//                NotificationManager.IMPORTANCE_DEFAULT
//            )
//            val manager = getSystemService(NotificationManager::class.java)
//            manager.createNotificationChannel(channel)
//        }
//    }
//
//    override fun onDestroy() {
//        super.onDestroy()
//        fusedLocationClient.removeLocationUpdates(locationCallback)
//    }
//
//    override fun onBind(intent: Intent?): IBinder? {
//        return null
//    }
//}








