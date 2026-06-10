# Twitter/X Article Enrichment

Some bookmarks are X Articles (Notes) where the `text` field is just a URL like `x.com/i/article/...`. These need enrichment before categorization.

## Fetching X Article content

Use Twitter's internal GraphQL API with the `TweetResultByRestId` endpoint and `fieldToggles.withArticlePlainText: true`:

```bash
TWEET_ID="<tweet_id_from_bookmark_url>"
TWITTER_BEARER_TOKEN="${TWITTER_BEARER_TOKEN:?set from current X web app request headers}"
VARIABLES='{"tweetId":"'$TWEET_ID'","withCommunity":false,"includePromotedContent":false,"withVoice":false}'
FEATURES='{"articles_preview_enabled":true,"responsive_web_twitter_article_tweet_consumption_enabled":true,"longform_notetweets_consumption_enabled":true,"longform_notetweets_rich_text_read_enabled":true}'
FIELD_TOGGLES='{"withArticleRichContentState":false,"withArticlePlainText":true}'

curl -sG "https://x.com/i/api/graphql/qxWQxcMLiTPcavz9Qy5hwQ/TweetResultByRestId" \
  --data-urlencode "variables=$VARIABLES" \
  --data-urlencode "features=$FEATURES" \
  --data-urlencode "fieldToggles=$FIELD_TOGGLES" \
  -H "authorization: Bearer $TWITTER_BEARER_TOKEN" \
  -H "x-csrf-token: $CT0" \
  -H "x-twitter-auth-type: OAuth2Session" \
  -H "cookie: auth_token=$AUTH_TOKEN; ct0=$CT0"
```

Response path: `data.tweetResult.result.article.article_results.result.plain_text` (full text) and `.title`.

Auth: uses the same `cookies.txt` from fetch-bookmarks.sh. Capture the current bearer token from an authenticated X web request or browser devtools; do not commit literal tokens. The GraphQL query ID may rotate — check gallery-dl releases if it breaks.

Treat `TWITTER_BEARER_TOKEN`, `AUTH_TOKEN`, `CT0`, and `cookies.txt` as secrets:

- Keep `cookies.txt` ignored by git and `chmod 600`.
- Do not echo auth environment variables or paste request headers into notes.
- If a command fails, report the error class (auth, rate limit, query ID rotated), not the raw response when it may include request headers.

## Processing enriched articles

1. For each article bookmark, extract the tweet ID from the URL and fetch via the endpoint above
2. Replace the URL-only `text` with the fetched `plain_text` content
3. If fetch fails (rate limit, auth expired), categorize based on author and any surrounding text
4. Rate limit: ~2 requests/second is safe

For thread references (`x.com/.../status/...` links in the text), fetch the referenced tweet if the bookmark text alone lacks enough context to categorize.
