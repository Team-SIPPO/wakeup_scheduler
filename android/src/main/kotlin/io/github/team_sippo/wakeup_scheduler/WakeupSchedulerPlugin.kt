package io.github.team_sippo.wakeup_scheduler

import android.app.Activity
import android.content.Intent
import android.os.Handler
import androidx.annotation.NonNull
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

const val LOG_TAG:String = "wakeup_schedule"

/** WakeupSchedulerPlugin */
class WakeupSchedulerPlugin: FlutterPlugin, EventChannel.StreamHandler, MethodCallHandler, PluginRegistry.NewIntentListener,
  ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var scheduleChannel: EventChannel
  private var activity: Activity? = null
  private var events: EventSink? = null
  private var binding: ActivityPluginBinding? = null

  private val currentReaderMode: String? = null
  private var lastTag: String? = null
  private var resultBuffer: MutableList<String> = mutableListOf();  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wakeup_scheduler")
    channel.setMethodCallHandler(this)
    scheduleChannel = EventChannel(flutterPluginBinding.binaryMessenger, "wakeup_scheduler/schedule")
    scheduleChannel.setStreamHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun handleSchedule(tag: String) {
    Log.d(LOG_TAG, "---------------")
    Log.d(LOG_TAG, tag.toString())
    Log.d(LOG_TAG, "---------------")
    if (this.events == null){
      resultBuffer.add(tag)
    } else{
      eventSuccess(tag)
    }
  }

  private fun eventSuccess(result: Any?) {
    val mainThread = Handler(activity!!.mainLooper)
    val runnable = Runnable {
      if (events != null) {
        // Event stream must be handled on main/ui thread
        events!!.success(result)
      }
    }
    mainThread.post(runnable)
  }

  private fun eventError(code: String, message: String, details: Any?) {
    val mainThread = Handler(activity!!.mainLooper)
    val runnable = Runnable {
      events?.error(code, message, details)
    }
    mainThread.post(runnable)
  }

  override fun onNewIntent(intent: Intent): Boolean {
    Log.d(LOG_TAG, "schedule intent recieved.")
    val action: String? = intent.action
    val type: String? = intent.type
    if (Intent.ACTION_SEND == action && type != null) {
      if ("text/plain" == type) {
        android.util.Log.d(LOG_TAG, "onCreate: intent get")
        // var tag: String? = intent.getStringExtra(Intent.EXTRA_TEXT)
        var tag: String? = intent.getStringExtra("wakeup_tag")
        if(tag == null){
          tag = ""
        }
        lastTag = tag
        Log.d(LOG_TAG, tag.toString())
        //handleSendText(intent) // Handle text being sent
        handleSchedule(tag)
        return true
      }
    }
    return false
  }

  override fun onListen(arguments: Any?, eventSink: EventSink?) {
    val flag = events == null
    this.events = eventSink
    if(flag){
      for(result in resultBuffer){
        eventSuccess(result)
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    events = null
  }

  private fun handleIntent(intent: Intent, initial: Boolean) {
    onNewIntent(intent);
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(LOG_TAG, "onAttachedToActivity")
    this.binding = binding
    this.activity = this.binding!!.activity
    binding.addOnNewIntentListener(this)
    handleIntent(binding.activity.intent, true)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    binding?.removeOnNewIntentListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.binding = binding
    binding.addOnNewIntentListener(this)
  }

  override fun onDetachedFromActivity() {
    binding?.removeOnNewIntentListener(this)
  }

}
