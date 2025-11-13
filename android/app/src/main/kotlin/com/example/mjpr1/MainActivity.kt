package com.example.mjpr1

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import ai.onnxruntime.*
import java.nio.FloatBuffer

class MainActivity : FlutterActivity() {

    private val CHANNEL = "oggrow/onnx_runtime"
    private var env: OrtEnvironment? = null
    private var session: OrtSession? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ✅ Initialize ONNX model
                    "initialize" -> {
                        val modelPath = call.argument<String>("modelPath")
                        initializeModel(modelPath, result)
                    }

                    // ✅ Run prediction
                    "predict" -> {
                        runInference(call, result)
                    }

                    // ✅ Dispose resources
                    "dispose" -> {
                        disposeModel()
                        result.success(true)
                    }

                    // ✅ Check ONNX runtime availability
                    "checkOrt" -> {
                        result.success(
                            mapOf(
                                "available" to true,
                                "version" to "unknown" // fallback since no version API available
                            )
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ✅ Initialize ONNX model session
    private fun initializeModel(modelPath: String?, result: MethodChannel.Result) {
        try {
            if (modelPath.isNullOrEmpty()) {
                result.error("MODEL_PATH_MISSING", "Model path not provided", null)
                return
            }

            Log.i("ONNX", "🧠 Initializing ONNX model from: $modelPath")

            env = OrtEnvironment.getEnvironment()
            val options = OrtSession.SessionOptions()
            session = env!!.createSession(modelPath, options)

            val inputs = session!!.inputNames
            val outputs = session!!.outputNames

            Log.i("ONNX", "✅ Model loaded successfully: $modelPath")
            Log.i("ONNX", "Inputs: $inputs")
            Log.i("ONNX", "Outputs: $outputs")

            result.success("Model initialized successfully.")
        } catch (e: Exception) {
            Log.e("ONNX", "❌ Model init failed: ${e.message}", e)
            result.error("MODEL_INIT_FAILED", e.message, null)
        }
    }

    // ✅ Run inference on input data
    private fun runInference(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (session == null) {
                result.error("MODEL_NOT_INITIALIZED", "ONNX session is null", null)
                return
            }

            val inputList = (call.argument<List<Any>>("inputs") ?: emptyList())
                .map { (it as Number).toFloat() }
            val shapeList = (call.argument<List<Any>>("shape") ?: emptyList())
                .map { (it as Number).toLong() }
            val inputName = call.argument<String>("inputName") ?: "float_input"

            if (inputList.isEmpty() || shapeList.isEmpty()) {
                result.error("INVALID_INPUT", "Input data or shape is empty", null)
                return
            }

            val inputArray = FloatBuffer.allocate(inputList.size)
            inputList.forEach { inputArray.put(it) }
            inputArray.rewind()

            Log.i("ONNX", "🌾 Sending inputs to ONNX: $inputList, shape: $shapeList")

            val tensor = OnnxTensor.createTensor(env, inputArray, shapeList.toLongArray())
            val outputs = session!!.run(mapOf(inputName to tensor))

            Log.i("ONNX", "🧠 Model output names: ${session!!.outputNames}")

            val outputLabel = outputs[0].value as? LongArray
            val outputProbRaw = outputs[1].value

            Log.i("ONNX", "🧩 Output Label: ${outputLabel?.contentToString()}")
            Log.i("ONNX", "🧩 Raw Probability Output Type: ${outputProbRaw?.javaClass?.simpleName}")

            val probabilities = mutableListOf<Double>()

            when (outputProbRaw) {
                is List<*> -> {
                    // ✅ Model returned sequence of OnnxMap objects
                    outputProbRaw.forEach { item ->
                        if (item is OnnxMap) {
                            val mapValues = item.value as Map<*, *>
                            mapValues.values.forEach {
                                if (it is Float) probabilities.add(it.toDouble())
                            }
                            item.close() // cleanup
                        }
                    }
                }

                is OnnxMap -> {
                    // ✅ Model returned a single OnnxMap
                    val mapValues = outputProbRaw.value as Map<*, *>
                    mapValues.values.forEach {
                        if (it is Float) probabilities.add(it.toDouble())
                    }
                    outputProbRaw.close()
                }

                else -> {
                    Log.w("ONNX", "⚠️ Unknown output type: ${outputProbRaw?.javaClass?.simpleName}")
                }
            }

            Log.i("ONNX", "✅ Extracted probabilities: $probabilities")

            outputs.close()
            tensor.close()

            result.success(probabilities)
        } catch (e: Exception) {
            Log.e("ONNX", "⚠️ ONNX inference failed: ${e.message}", e)
            result.error("ONNX_RUN_FAILED", e.message, null)
        }
    }

    // ✅ Dispose model and environment
    private fun disposeModel() {
        try {
            session?.close()
            env?.close()
            session = null
            env = null
            Log.i("ONNX", "🧹 ONNX resources cleaned up.")
        } catch (e: Exception) {
            Log.e("ONNX", "Error disposing ONNX resources: ${e.message}", e)
        }
    }
}
