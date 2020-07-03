exports.handler = async event => {
  const subject = event.queryStringParameters.name || "World";

  const stripe = require("stripe")("sk_test_D6RF8TPpIHosXCs0Nk5zzUum");

  var session = await stripe.billingPortal.sessions.create({
    customer: "cus_HZSNNTtJhCIyzp",
    return_url: "https://bullish.email"
  });

  return {
    statusCode: 200,
    headers: {
      Location: session.url
    }
  };
};