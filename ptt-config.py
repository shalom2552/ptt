# ptt-config.py - nerd-dictation user config. Runs on every utterance after
# nerd-dictation's own processing, so text arrives capitalized by
# --full-sentence and numbers are already digits.

# Spoken phrase to mark. Attaches to the word before it, with no space.
PUNCTUATION = {
    "period": ".",
    "comma": ",",
    "colon": ":",
    "semicolon": ";",
    "question mark": "?",
    "exclamation mark": "!",
    "exclamation point": "!",
    "new line": "\n",
}

# Spoken phrase to text. Stands on its own as a word.
WORDS = {}


def _phrase_lengths(*tables):
    return sorted({len(phrase.split()) for t in tables for phrase in t}, reverse=True)


def _replace(words):
    lengths = _phrase_lengths(PUNCTUATION, WORDS)
    out = []
    i = 0
    while i < len(words):
        # Longest phrase first, so "question mark" beats a "mark" entry.
        for size in lengths:
            phrase = " ".join(words[i : i + size]).lower()
            if phrase in PUNCTUATION:
                if out:
                    out[-1] += PUNCTUATION[phrase]
                else:
                    out.append(PUNCTUATION[phrase])
                i += size
                break
            if phrase in WORDS:
                out.append(WORDS[phrase])
                i += size
                break
        else:
            out.append(words[i])
            i += 1
    return out


def nerd_dictation_process(text):
    return " ".join(_replace(text.split())).replace("\n ", "\n")
