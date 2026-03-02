import torch
import coremltools as ct

from utils.model import ASLClassifier

thismodel = ASLClassifier(num_classes=29)
thismodel.load_state_dict(torch.load("asl_cnn.pth", map_location="cpu"))
thismodel.eval()


sample_input = torch.rand(1,1, 224,224)

mlmodel = ct.convert(
    thismodel,
    inputs=[ct.TensorType(shape=sample_input.shape)]
)

mlmodel.save("ASLCLassifier.mlmodel")
print("Saved ASLCLassifier.mlmodel")