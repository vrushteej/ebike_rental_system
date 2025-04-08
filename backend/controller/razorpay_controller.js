const paymentService = require("../services/razorpay_services");

// **Create a payment order**
const createPayment = async (req, res) => {
    try {
        const { userId, rideId, payment_method } = req.body;

        // ✅ Validate request body
        if (!userId || !rideId || !payment_method) {
            return res.status(400).json({ 
                success: false, 
                message: "Missing required fields: userId, rideId, or payment_method." 
            });
        }

        const response = await paymentService.createOrder(userId, rideId, payment_method);
        
        if (response.error) {
            return res.status(400).json({ success: false, message: response.error });
        }

        return res.status(200).json({ success: true, message: "Payment order created", data: response });

    } catch (error) {
        console.error("Error creating payment:", error);
        return res.status(500).json({ success: false, message: "Internal server error", error: error.message });
    }
};

// **Verify Payment**
const verifyPayment = async (req, res) => {
    try {
        const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;

        // ✅ Validate request body
        if (!razorpay_payment_id || !razorpay_order_id || !razorpay_signature) {
            return res.status(400).json({ 
                success: false, 
                message: "Missing required payment verification fields." 
            });
        }

        const response = await paymentService.verifyPayment(razorpay_payment_id, razorpay_order_id, razorpay_signature);
        
        return res.status(200).json({ success: true, message: response.message, data: response.payment });

    } catch (error) {
        console.error("Error verifying payment:", error);
        return res.status(400).json({ success: false, message: "Payment verification failed", error: error.message });
    }
};

module.exports = { createPayment, verifyPayment };
