
require("dotenv").config();
const Razorpay = require("razorpay");
const Payment = require("../models/razorpay_model");
const Ride = require("../models/ride_model");
const crypto = require("crypto");

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_SECRET
});

// **Create Razorpay Order**
const createOrder = async (userId, rideId, payment_method) => {
    const ride = await Ride.findById(rideId);
    if (!ride) throw new Error("Ride not found");

    const existingPayment = await Payment.findOne({ rideId, status: "pending" });
    if (existingPayment) return { error: "Payment already in progress" }; // ✅ Prevent duplicate orders

    const options = {
        amount: ride.amount * 100, 
        currency: "INR",
        receipt: `receipt_${rideId}`
    };

    const order = await razorpay.orders.create(options);

    const payment = new Payment({
        userId,
        rideId, 
        amount: ride.amount, 
        payment_method,
        razorpay_order_id: order.id,
        status: "pending"
    });

    await payment.save();
    return { order, payment };
};

const verifyPayment = async (payment_id, order_id, signature) => {
    const expectedSignature = crypto.createHmac("sha256", process.env.RAZORPAY_SECRET)
        .update(order_id + "|" + payment_id)
        .digest("hex");

    if (expectedSignature !== signature) {
        await Payment.findOneAndUpdate(
            { razorpay_order_id: order_id },
            { status: "failed" }
        );
        throw new Error("Invalid payment signature");
    }

    const payment = await Payment.findOneAndUpdate(
        { razorpay_order_id: order_id },
        { status: "successful", razorpay_payment_id: payment_id, razorpay_signature: signature },
        { new: true }
    );

    if (!payment) throw new Error("Payment record not found!");

    return { message: "Payment successful", payment };
};


module.exports = { createOrder, verifyPayment };

