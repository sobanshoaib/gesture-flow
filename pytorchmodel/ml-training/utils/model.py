import torch
import torch.nn as nn
import torch.nn.functional as F


# will contain the CNN architecture (neural network that learns to classify asl)

class ASLClassifier(nn.Module):

    # creates layers. everything the model wants to learn is in these layers
    def __init__(self, num_classes=29):
        super().__init__()

        #extract simple features like edges. first conv layer
        self.conv1 = nn.Conv2d(
            in_channels=1,
            out_channels=32,
            kernel_size=3,
            padding=1
        )

        # extract more complex features. second conv layer
        self.conv2 = nn.Conv2d(
            in_channels=32,
            out_channels=64,
            kernel_size=3,
            padding=1
        )

        self.pool = nn.MaxPool2d(2,2)

        self.dropout = nn.Dropout(0.3)

        self.fc1 = nn.Linear(64 * 56 * 56, 256)
        self.fc2 = nn.Linear(256, num_classes)

    def forward(self, x):
        # how the data moves through the network
        x = self.pool(F.relu(self.conv1(x)))

        x = self.pool(F.relu(self.conv2(x)))

        x = torch.flatten(x,1)

        x = self.dropout(F.relu(self.fc1(x)))
        x = self.fc2(x)

        return x