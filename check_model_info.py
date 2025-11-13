import onnx

# use full path to your model file
m = onnx.load(r"C:\Users\Harshith\Desktop\sharerd-main\assets\models\crop_prediction_model_ir9.onnx")

print("✅ Model Info:")
print("Opset:", m.opset_import[0].version)
print("Inputs:", [i.name for i in m.graph.input])
print("Outputs:", [o.name for o in m.graph.output])
