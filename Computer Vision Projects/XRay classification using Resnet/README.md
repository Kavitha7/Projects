**### Objective:** To identify images where an "effusion" is present. This is a classification problem, where we will be dealing with two classes - 'effusion' and 'nofinding'. Here, the latter represents a "normal" X-ray image.

The data preprocessing and network building involve the following steps.

**### Data preprocessing:**

1. Augmentation
2. Resizing
3. Normalization

**### Network building:**

1. Using Resnet 18 architecture.
2. Weighted cross enropy to deal with class imbalance.
3. Evaluation metric - AUC
