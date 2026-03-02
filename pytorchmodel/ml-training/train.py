# responsible for loading dataset, creating model, and more. will validate model and save trained file


import torch
import torch.nn as nn
import torch.optim as optim

from utils.dataset import data_load
from utils.model import ASLClassifier

if torch.cuda.is_available():
    device = torch.device("cuda")
else:
    device = torch.device("cpu")

print("using device", device)

# gives batches. train laoder used to teach the model. val loader used to check accuracy
train_loader, val_loader = data_load(
    data_dir="data/ASL_Alphabet_Dataset",
    img_size=224,
    batch_size=32
)


model = ASLClassifier(num_classes=29)
model = model.to(device)

# loss function. how wrong model is
criterion = nn.CrossEntropyLoss()

# optimizer. how model learns
optimizer = optim.Adam(model.parameters(), lr=0.001)





num_epochs = 10

for epoch in range(num_epochs):
    model.train() #put model in training mode
    run_loss = 0.0

    # guess, measure mistake, fix weights
    for images, labels in train_loader:
        images = images.to(device)
        labels = labels.to(device)

        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        run_loss += loss.item()

    average_loss = run_loss / len(train_loader)
    print(f"[{epoch+1}/{num_epochs}], Loss: {average_loss: .4f}")

    model.eval() #put model in evaluation mode. no learning happens here
    correct = 0
    total = 0

    with torch.no_grad():
        for images, labels in val_loader:
            images = images.to(device)
            labels = labels.to(device)

            outputs = model(images)
            _, predicted = torch.max(outputs, 1)

            total += labels.size(0)
            correct += (predicted == labels).sum().item()

    accuracy = 100 * correct / total
    print(f"Validation accuracy: {accuracy:.2f}%")

torch.save(model.state_dict(), "asl_cnn.pth")
print("model saved as asl_cnn.pth")
    
