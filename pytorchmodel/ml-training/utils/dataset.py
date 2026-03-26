from torchvision import datasets, transforms
from torch.utils.data import DataLoader, random_split
import os






def get_transform(img_size=224):
    return transforms.Compose([
        transforms.Grayscale(num_output_channels=1),
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.5], std=[0.5])
    ])



def data_load(data_dir="data/ASL_Alphabet_Dataset", img_size=224, batch_size=32):
    
    # prepares raw image file into learning-ready data. defines how every image will be cleaned
    transform = get_transform(img_size)

    # load dataset. automatically reads folders (so in our folder, we could have A/, B/, each folder will become a label)
    print(os.path.join(data_dir, "asl_alphabet_train"))
    print(os.path.exists(os.path.join(data_dir, "asl_alphabet_train")))


    dataset = datasets.ImageFolder(
        os.path.join(data_dir, "asl_alphabet_train"),
        transform=transform
    )

    print("Classes:", dataset.classes)
    print("Class to idx:", dataset.class_to_idx)

    train_size = int(0.8*len(dataset))
    val_size = len(dataset) - train_size

    
    training_dataset, validation_dataset = random_split(dataset, [train_size, val_size])


    # creating data loaders
    # Dataloader groups images into batches (32 at a time), and shuffles for better learning, and sends data to gpu
    training_loader = DataLoader(training_dataset, batch_size=batch_size, shuffle=True)
    validation_loader = DataLoader(validation_dataset, batch_size=batch_size, shuffle=False)

    return training_loader, validation_loader
