import { json } from '@sveltejs/kit';
import midtransClient from 'midtrans-client';
import { MIDTRANS_SERVER_KEY } from '$env/static/private';

const snap = new midtransClient.Snap({
  isProduction: false,
  serverKey: MIDTRANS_SERVER_KEY
});

export async function POST({ request }) {
  const { userId, plan } = await request.json();

  const parameter = {
    transaction_details: {
      order_id: `ORDER-${userId}-${Date.now()}`,
      gross_amount: 50000 // example 50k IDR
    },
    credit_card: {
      secure: true
    },
    customer_details: {
      first_name: "User",
      email: "user@example.com"
    }
  };

  try {
    const transaction = await snap.createTransaction(parameter);
    return json({ token: transaction.token, redirect_url: transaction.redirect_url });
  } catch (error: any) {
    return json({ error: error.message }, { status: 500 });
  }
}
