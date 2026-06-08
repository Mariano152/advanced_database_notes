# Session - 2026-04-07

## Topics covered
- Oracle 23ai Vector Search.
- Vector embeddings generated from Wikipedia article paragraphs.
- Using `VECTOR(384, FLOAT32)` columns to store embeddings.
- Using `VECTOR_DISTANCE` with cosine distance to compare a natural-language question with stored text chunks.
- Understanding that vector search compares semantic meaning instead of exact keywords.

## What I understood
- I understood that the notebook has two main phases. First, it prepares the data by downloading a Wikipedia article, splitting it into chunks, and generating one vector embedding for each chunk. Then, it loads those vectors into Oracle 23ai so they can be searched with SQL.
- I also understood that the search question is converted into a vector too. Oracle compares that question vector against the stored chunk vectors using `VECTOR_DISTANCE`. The closest rows are the chunks with the most similar meaning.
- A cosine distance close to `0.0` means the result is very similar to the question. A higher score means the result is less related.

## What is still confusing
- 

## Questions
- 

## Related concepts
- [Concept name](../concepts/concept-name.md)

## Resources used
- See `resources/`
