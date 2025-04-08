const express = require("express");
const paymentController = require("../controller/razorpay_controller");

const router = express.Router();

router.post("/create-payment", paymentController.createPayment);
router.post("/verify-payment", paymentController.verifyPayment);

module.exports = router;
