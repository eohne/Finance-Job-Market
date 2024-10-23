# Job Posting Scraper

This package scrapes academic job postings from various platforms like SSRN and AFA. Additionally, it provides the option to use AI tools to extract structured information from job postings for easier analysis.


> **⚠️ Disclaimer**
>
> Please note that this code may exhibit slow performance due to the following reasons:
>
> 1. **Downloading SSRN Files**: Retrieving files from SSRN can be time-consuming because SSRN implements request throttling. To manage this, exponential wait times for retries are incorporated, which can significantly increase the total download time.
> 
> 2. **AI Processing Speed**: The processing speed of the AI model varies depending on the environment:
>    - Using the **Mistral API** for processing 200 SSRN entries took approximately **1 to 2 hours**.
>    - While the **local Mistral-Nemo model** can be faster (depends on your hardware), it operates with a less powerful model, impacting overall performance.
>    - Downloading **200 SSRN files** typically takes about **1 hour**.
>    - In contrast, downloading **100 AFA files** is nearly instantaneous.
>
> Keep these factors in mind when planning your usage of the script, as they may affect the overall efficiency and completion time.
> **Note that the program checks for already downloaded and processed entries and will not reprocess those**


## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Usage](#usage)
- [AI Configuration](#ai-configuration)
  - [Using Ollama](#using-ollama)
  - [Using Mistral API](#using-mistral-api)
- [Data Files](#data-files)
- [Output](#output)

## Overview
This package is designed to automate the process of scraping job postings from websites like SSRN and AFA. In addition to scraping, it provides optional AI-based processing for job data extraction. Users can choose between using **Ollama** (for local AI processing) or the **Mistral API** (for cloud-based AI processing) to summarize and extract details such as application deadlines and required documents.

## Features
- Scrapes job postings from SSRN and AFA.
- AI-assisted extraction of job details (deadlines, application links, required documents).
- Support for two AI options:
  - **Ollama** for local processing.
  - **Mistral API** for cloud-based processing.
- Outputs scraped data to CSV files for further use.

## Dependencies
The following Julia packages are required:
- `HTTP`
- `Gumbo`
- `DataFrames`
- `ProgressMeter`
- `CSV`
- `Dates`
- `JSON3`
- `PromptingTools`
- `Suppressor`

These packages are automatically installed when the program is executed for the first time.

## Installation
Clone the repository and navigate to the project directory:
```bash
git clone https://github.com/your-repo/job-posting-scraper.git
cd job-posting-scraper
```

To install dependencies, simply run the main script:
```julia
include("main_script.jl")
```


## Usage
The script prompts you with configuration options during runtime, where you can choose:
- Whether to use AI for information extraction.
- Whether to use Ollama for local processing or the Mistral API for cloud-based processing.

Run the main script to start scraping and processing:
```julia
julia main_script.jl
```

### Workflow
1. The scraper retrieves job postings from SSRN and AFA.
2. If AI is enabled, new job postings are processed using AI to extract structured information.
3. Data is saved into CSV files:
   - Non-AI processed data: `Output/Jobs.csv`
   - AI-processed data: `Data/ssrn_ai.csv` and `Data/afa_ai.csv`

> **Warning:** Please do not change the created CSV files directly. Make a copy of them and modify the copies as needed for subsequent runs. This will help preserve the original data.


## AI Configuration
This project supports two methods for AI-based information extraction from job postings. Note that the results may change between runs and that the models can make mistakes.

### Local Mistral-Nemo vs. Mistral-Medium via API: Quick Comparison

| Aspect              | **Mistral-Nemo (Local, via Ollama)**                            | **Mistral-Medium (via API)**                   |
|---------------------|----------------------------------------------------------------|------------------------------------------------|
| **Hardware Needs**   | Requires a **GPU** for optimal performance; check VRAM availability with Ollama. The model size is **7.1 GB**, and it’s a 12B parameter model with a **128k context length**, which typically requires **16GB+ of VRAM**. | No special hardware required; inference done on external servers. |
| **Token Limits**     | N/A (No usage limits locally)                                  | Free API limits: **500,000 tokens per minute**, **1 billion tokens per month** (should be sufficient). |
| **Performance**      | Local inference may have **lower latency** but requires proper GPU resources to handle the model effectively. | API model is larger and may offer **better performance** at the cost of potential network latency. |

For local use, ensure your GPU has sufficient VRAM for the model size. The free API provides ample token capacity for typical workloads.

### Using Ollama
Ollama allows for local AI processing on your machine. Follow these steps to set it up:
1. Install [Ollama](https://ollama.com) by following their instructions for your operating system.
2. Start an Ollama server (detailed instructions here)
3. During runtime, when prompted:
   - Select `y` (yes) to use Ollama.

#### Details: Installing and Serving the **mistral-nemo** Model for Ollama

To install and serve the `mistral-nemo` model for use with Ollama, follow these steps based on your operating system:

##### Steps for All Operating Systems:
1. **Open the command line** on your machine:
   - **Windows**: Use `Command Prompt` or `PowerShell`.
   - **macOS or Linux**: Use `Terminal`.

2. **Install the `mistral-nemo` model** by running the following command:
   ```bash
   ollama pull mistral-nemo
   ```
   This command will download the `mistral-nemo` model to your local machine.

3. After the model is installed, you can **serve the model locally** by running:
   ```bash
   ollama serve
   ```
   This command will start the Ollama service, making the `mistral-nemo` model available for use.


##### Ending the Ollama Service:

4. When you're finished, you can **stop the Ollama service** as follows:

- **Windows**:
   - Close the terminal window running the service **or** use this command to terminate it forcefully:
     ```bash
     taskkill /fi "imagename eq ollama app.exe"
     ```
- **macOS or Linux**:
   - You can stop the service by pressing `Ctrl + C` in the terminal window running Ollama **or** use the following command to stop the process:
     ```bash
     pkill ollama
     ```

By following these steps, you can easily install, serve, and stop the `mistral-nemo` model using Ollama on any operating system.


### Using Mistral API  - Model used: mistral-medium
The Mistral API provides cloud-based AI processing. To use it:
1. Sign up for an API key at the [Mistral website](https://mistral.com/api) (if needed).
2. During runtime, when prompted:
   - Select `n` (no) for Ollama.
   - Enter your Mistral API key when asked (you can skip this by pressing Enter, but AI processing will not occur without a valid key).

If you do not provide an API key, AI processing will be skipped, and only the basic job scraping will be performed.

## Data Files
The script works with the following files:
- **Input:**
  - `Data/ssrn.csv` - Existing SSRN job postings.
  - `Data/afa.csv` - Existing AFA job postings.
  - `Data/ssrn_ai.csv` - Previously processed SSRN job postings with AI.
  - `Data/afa_ai.csv` - Previously processed AFA job postings with AI.
- **Output:**
  - `Output/Jobs.csv` - The final consolidated job postings, including newly scraped and AI-processed data.

> **Warning:** Please do not change the created CSV files directly. Make a copy of them and modify the copies as needed for subsequent runs. This will help preserve the original data.


## Output
The scraped job postings are saved in CSV format. If AI processing is used, extracted details such as application deadlines, required documents, and job posting IDs will be included in the output.