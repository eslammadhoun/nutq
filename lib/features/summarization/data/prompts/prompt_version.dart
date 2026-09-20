/// Bump when any prompt template changes; it is part of the cache key, so a
/// new value invalidates every cached generation.
const String summarizationPromptVersion = 'v1';

/// Identifies the bundled model; stored with every summary it produces.
const String summarizationModelId = 'gemma3-1b-it-q4';
