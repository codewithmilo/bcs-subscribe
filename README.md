# Blockchain Services - Subscribe

An MVP for a blockchain-backed subscription service.

It works by utilizing two tokens: a subscription token and a duration token. The subscription token holds the equivalent of an "account" while the duration token designates the length of the subscription until expiration. The act of subscribing means minting a subscription token and buying the desired duration token. Then, during any "log in" or authentication type action, the provider can check the status of the subscription by confirming the S token is held, while checking the D token has not yet expired.

The benefit of this pattern is putting all control over the subscription with the user. Services no longer need to keep any private information about the user, and the user has full autonomy to cancel/unsubscribe.
