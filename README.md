# Stable Diffusion Convenience Scripts

These are my scripts for using Stable Diffusion.

## Prerequisites

1. Install `fzf` by executing:

   ```bash
   brew install fzf
   ```

2. Clone [`kohya_ss`](https://github.com/bmaltais/kohya_ss) (for training scripts):

   ```bash
   git clone git@github.com:bmaltais/kohya_ss.git
   ```

## Installation

1. Clone this repository:

   ```bash
   git clone git@github.com:Danand/stable-diffusion-scripts.git
   ```

2. Add this repository to the `PATH` variable:

   ```bash
   cd stable-diffusion-scripts && \
   echo "export PATH=\"\${PATH}:$(pwd)\"" >> ~/.bashrc
   ```

## Usage

### Model Management

These scripts rely on reusable model folders linked to Stable Diffusion UI wrappers via symlinks:

- [**ComfyUI**](https://github.com/comfyanonymous/ComfyUI)
- [**A1111**](https://github.com/AUTOMATIC1111/stable-diffusion-webui)

#### Initialize Model Folders

```bash
sd-models-init.sh
```

Creates the valid folder layout for further symlinks.

#### Link Models

```bash
sd-models-link.sh
```

Links models from the current working directory (CWD) to Stable Diffusion UI wrappers.

#### Link Trained LoRA

```bash
sd-models-link-trained-lora.sh
```

Links trained LoRA from CWD to Stable Diffusion UI wrappers.

### LoRA Training

#### Initialize LoRA Training Folders

```bash
sd-train-init.sh
```

Creates a valid folder layout for further training with `kohya_ss` scripts.

#### Interactive LoRA training

```bash
sd-train-lora-fzf.sh
```

Runs an interactive launch of LoRA training via `kohya_ss` scripts. The steps involved are:

1. Set `KOHYA_SS_PATH` and `SD_MODELS_PATH` if they differ from the parent directory `HOME`.
2. Choose the base model (from `SD_MODELS_PATH`).
3. Choose the training scripts (from `KOHYA_SS_PATH`).
4. Enter the number of training epochs (default: `3`).
5. Enter the training width (default: `512`).
6. Enter the training height (default: `512`).
7. Enter the training seed (default: `12345`).
8. Enter the network dimension (default: `128`).
9. Enter the network alpha (default: `128`).
10. Enter the learning rate (default: `0.0001`).
11. Enter the U-Net learning rate (default: `0.0001`).
12. Enter the text encoder learning rate (default: `5e-5`).
13. Enter the noise offset (default: `0.0`).
14. Choose a sampler (a list of compatible samplers will be provided by the script).

#### Set up weights of images for LoRA training

```bash
sd-train-subsets-weights-edit.py
```

Sets the number of repeats per each subdirectory of `images` based on an interactively entered "weight".

## FAQ: LoRA Training

### What is the difference between "Repeats", "Steps", and "Epochs"?

- "Step" is the actual iteration of training.
- "Repeats" is the number used to set up the weight of each training subject subset of images.
- "Epochs" is the multiplier of total steps. The trained LoRA can be saved as a ready-to-use model on each epoch.

### Still can't understand the difference between "Repeats", "Steps", and "Epochs"?

Take a look at the training images folder:

```bash
images/
  1_SubjectName/ # Let's assume that there are 15 images in this folder.
  3_SubjectName/ # Let's assume that there are 5 images in this folder.
```

Let's assume that images from the folder `1_SubjectName` are equally important for defining `SubjectName` (e.g., anime character or specific style) as those from `3_SubjectName`. However, there are 15 images in `1_SubjectName`, making `1_SubjectName` 3 times heavier than `3_SubjectName` in terms of weight. The magic numbers in folder name prefixes ("repeats") - `1_` and `3_` - are used as multipliers for the number of images in each folder. So, the total steps per each folder are:

- `1_SubjectName`: `15 images * 1 repeats # 15 steps`
- `3_SubjectName`: `5 images * 3 repeats # 15 steps too`

Now, each folder is equally important for training the subject `SubjectName`, and the total steps for the subject are 30.

"Epochs" is just a multiplier for the total number of steps. For instance, if we want to train a model with a total of 3000 steps, we set epochs to 100 here.

## How to prepare Dataset for training

The dataset (or training images) should:

- be of the same size
- have the same size as specified on the launch of training
- be placed in subset folder(s) named `N_SubjectName`, where:
  - `N` is the number of repeats for this folder
  - `SubjectName` is a unique tag for triggering this subject with a prompt
- be provided with caption files (same name as the image name but with a `.txt` extension)

_Same size of images_ – not necessarily. `kohya_ss` scripts support ["buckets"](https://github.com/bmaltais/kohya_ss/wiki/LoRA-training-parameters#enable-buckets): cropping input images in tiles automatically while learning; but it's slower.

You can use the [**Dataset Tag Editor** (for **A1111**)](https://github.com/toshiaki1729/stable-diffusion-webui-dataset-tag-editor) for interrogating captions.

### How many Steps are required for training LoRA?

To be honest, I don't know. Some articles suggest a magic number of **2500 steps** for training LoRA.

### Which Base Model to choose for training LoRA?

Choose the base model that is closest in style to your LoRA.

### Which Training Script to choose for training LoRA?

- `train_network.py` – trains LoRA with SD 1.5-based model
- `sdxl_train_network.py` – trains LoRA with SDXL-based model

You can find Base Model version on the page of the preferred base model at [**CivitAI**](https://civitai.com/models).

### Which Resolution to choose for training LoRA?

Resolution of training images. They must be resized and cropped to those values.

### Which Random Seed to choose for training LoRA?

It's random. Choose any. But you can enter the same seed each time for clearer comparison of results of training.

### Which Network Dim to choose for training LoRA?

The higher value, the more "cooked" (taking more effect) LoRA. You could start with 2 and increase by the power of 2:

- `2`
- `4`
- `8`
- `16`
- ...
- `128`
- ...

### Which Network Alpha to choose for training LoRA?

Try to set it as equal to "network dim" or less.

### Which Learning Rate to choose for training LoRA?

Start with `0.0001` and then decrease the value by 2 times.

- `0.0001`
- `0.00005`
- `0.000025`
- ...

### Which U-Net Learning Rate to choose for training LoRA?

Try to set it as equal to "learning rate" or less.

### Which Text Encoder Learning Rate to choose for training LoRA?

Start with `5e-5` and then decrease the value.

#### How to read numbers such as `5e-5`

It's `5 * (10 ** -5)` or `0.00005`.

You can check this by running formatting of the value with Python:

```bash
$ python3 -c 'print(format(5e-5, "f"))'
0.000050
```

#### Is weird formatting of numbers such as `5e-5` required for launch training?

Not necessarily. But it's often used in tutorials for learning rate values. I don't know why.

### Which Noise Offset to choose for training LoRA?

Default is `0.0`, but some tutorials suggest `0.1` for more contrast in images generated with trained LoRA. However, I didn't notice so. Generated images were even paler with noise offset `0.1` than with noise offset `0.0`.

### Which sampler to choose for training LoRA?

I preferred `dpm_2`. I think it takes fewer steps for generating quite good images with the `dpm_2` sampler.

## References

- [`kohya_ss` wiki](https://github.com/bmaltais/kohya_ss/wiki/LoRA-training-parameters)
- [The other LoRA training Rentry](https://rentry.org/59xed3)
