"""Example use of the generated SDK (run generate_sdk.bat first, backend running).
Method/model names come from the OpenAPI spec - see srs_sdk/docs/WordsApi.md."""
from srs_sdk import ApiClient, Configuration
from srs_sdk.api.words_api import WordsApi
from srs_sdk.models.review_create import ReviewCreate
from srs_sdk.models.word_create import WordCreate

with ApiClient(Configuration(host="http://localhost:8000")) as client:
    api = WordsApi(client)

    word = api.add_word(WordCreate(word="ephemeral", definition="short-lived", language="English"))
    print("added:", word)

    due = api.get_due_words()
    print("due today:", [w.word for w in due])

    print("review:", api.submit_review(word.id, ReviewCreate(score=5)))
    print("history:", api.get_history().accuracy, "% accuracy")
