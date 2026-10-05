# 🕵️ Hollowmere Case File: AI Detective Assistant

An AI-powered interactive murder mystery companion built with **Flutter**. Step into the shoes of Detective Inspector Dana Whitlock and investigate **CASE FILE 1014-HM: The Death of Edmund Harrow** by questioning a private, fully local AI assistant about clues, suspects, timelines, and forensic evidence.

Instead of relying on generic LLM knowledge, the app uses a lightweight, vector-less **local Retrieval-Augmented Generation (RAG)** pipeline so every answer is grounded in the case file.

---

## ✨ Features

- **Local RAG engine**: no vector database or embedding model required.
- **Fully offline and private**: runs on a local [Ollama](https://ollama.com/) instance.
- **Case-grounded answers**: responses come only from the case file, not general model knowledge.
- **Rich Markdown chat UI**: headings, tables, and lists render cleanly, and messages are selectable for copy-paste.
- **Typing indicator** while the local model generates a response.
- **One-tap reset** to start a fresh investigation.
- **Graceful error handling** if Ollama isn't running.

---

## 🧠 How It Works

```
User query ─► Keyword scoring ─► Top 5 chunks ─► System prompt + context ─► Ollama (gemma4:e4b) ─► Answer
```

1. **Chunking**: On startup, `Repository.chunkFiles` loads `hollowmere_case_file.md` from assets and splits it at every second-level header (`##` ). Each suspect profile, timeline entry, and evidence item becomes its own chunk.
2. **Retrieval**: `ChatService.buildSystemPrompt` tokenizes the user's query into unique lowercase keywords (dropping words under 3 characters), scores every chunk by keyword overlap, and keeps the top **5** chunks with at least one match.
3. **Prompting**: The retrieved chunks are merged into a `Context` block inside a strict system prompt: answer from the context in full sentences, respond normally to greetings, and otherwise say there is no relevant context.
4. **Generation**: The prompt and chat history (alternating `user` / `assistant` roles) are sent to Ollama at `http://localhost:11434/api/chat`.

---
## 🛠️ Tech Stack

|Layer|Technology|
|---|---|
|Framework|Flutter|
|State management|`provider`|
|Markdown UI|`flutter_markdown`|
|LLM runtime|Ollama (local)|
|Model|`gemma4:e4b`|
|Retrieval|Keyword-overlap scoring|

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Ollama](https://ollama.com/download) installed and running locally

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Muhtashim-Fuad/hollowmere-case-file.git
cd hollowmere-case-file

# 2. Pull the model
ollama pull gemma4:e4b

# 3. Make sure Ollama is running (default: http://localhost:11434)
ollama serve

# 4. Install dependencies
flutter pub get

# 5. Run the app
flutter run
```

> Make sure `hollowmere_case_file.md` is registered under `assets` in `pubspec.yaml`.

### Configuration

The model name and Ollama endpoint are set in `lib/services/chat_service.dart`. Change them there to use a different model or host.

---

## 🔍 The Case

**Victim:** Edmund Harrow, 64, owner of Harrow & Finch Galleries **Location:** The locked-from-the-inside study of Hollowmere Manor **Time of death:** Between 9:25 PM and 9:45 PM, Saturday 14 October **Cause of death:** Cardiac arrest from a lethal dose of digitoxin

**Persons of interest:**

1. Margaret Harrow, the wife
2. Julian Harrow, the son
3. Dr. Priya Nair, the family physician
4. Clara Voss, the art appraiser
5. Oliver Finch, the business partner
6. Thomas Greaves, the butler

Evidence, timelines, and statements are in the case file. Ask the assistant to uncover them. _No spoilers here._

---

## 💬 Example Questions

- _"Who had a motive to kill Edmund?"_
- _"Tell me about the cufflink found in the study."_
- _"Where was Oliver Finch during the murder?"_
- _"What did the toxicology report reveal?"_

---

## 🧩 Limitations

- Retrieval is keyword-based, so it won't catch synonyms or paraphrases. Phrase questions with specific names and terms.
- Only the top 5 chunks are passed as context.
- Answer quality depends on the local model you run.
