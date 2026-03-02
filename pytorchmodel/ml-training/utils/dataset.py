from torchvision import datasets, transforms
from torch.utils.data import DataLoader, random_split
import os


def data_load(data_dir="data/ASL_Alphabet_Dataset", img_size=224, batch_size=32):
    
    # prepares raw image file into learning-ready data. defines how every image will be cleaned
    transform = transforms.Compose([
        # asl dataset is grayscale, so reduces model size
        transforms.Grayscale(num_output_channels=1),
        
        transforms.Resize((img_size, img_size)),
        
        # pytorch doesnt want the images, it needs tensors
        transforms.ToTensor(),

        transforms.Normalize(mean=[0.5], std=[0.5])
    ])

    # load dataset. automatically reads folders (so in our folder, we could have A/, B/, each folder will become a label)
    print(os.path.join(data_dir, "asl_alphabet_train"))
    print(os.path.exists(os.path.join(data_dir, "asl_alphabet_train")))

    # training_dataset = datasets.ImageFolder(
    #     os.path.join(data_dir, "asl_alphabet_train"),
    #     transform=transform
    # )

    # validation_dataset = datasets.ImageFolder(
    #     os.path.join(data_dir, "asl_alphabet_test"),
    #     transform=transform
    # )

    dataset = datasets.ImageFolder(
        os.path.join(data_dir, "asl_alphabet_train"),
        transform=transform
    )

    training_dataset = int(0.8*len(dataset))
    validation_dataset = len(dataset) - training_dataset

    
    training_dataset, validation_dataset = random_split(dataset, [training_dataset, validation_dataset])


    # creating data loaders
    # Dataloader groups images into batches (32 at a time), and shuffles for better learning, and sends data to gpu
    training_loader = DataLoader(training_dataset, batch_size=batch_size, shuffle=True)
    validation_loader = DataLoader(validation_dataset, batch_size=batch_size, shuffle=False)

    return training_loader, validation_loader
