import torch
import coremltools as ct 
from utils.model import ASLClassifier



labels = [
    "A", "B", "C", "D", "del", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "nothing", "O", "P", "Q", "R", "S", "space", "T", "U", "V", "W", "X", "Y", "Z"
]


model = ASLClassifier(num_classes=29)
model.load_state_dict(torch.load("asl_cnn.pth", map_location="cpu"))
model.eval()
print("model loaded")

test_input = torch.rand(1,1,224,224)

with torch.no_grad():
    traced = torch.jit.trace(model, test_input)

print("model traced")

mlmodel = ct.convert(traced,
                     convert_to="neuralnetwork",
                    inputs=[
                        ct.ImageType(name="image", shape=(1,1,224,224), color_layout=ct.colorlayout.GRAYSCALE, scale=1/255.0)],
                        classifier_config=ct.ClassifierConfig(labels),)

print("converted to coreml")

mlmodel.save("ASLModel.mlmodel")

print("saved mlmodel file")