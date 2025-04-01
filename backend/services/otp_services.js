const twilio = require('twilio');
require('dotenv').config();

const client = new twilio(process.env.TWILIO_ACCOUNT_SID,process.env.TWILIO_AUTH_TOKEN);

class OTPService {
    static generateOTP() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }

    static async sendOTP(phone,otp) {
        try {
            await client.messages.create({
                body: `Your OTP is ${otp}.It is valid for 5 minutes`,
                from: process.env.TWILIO_PHONE_NUMBER,
                to: phone
            });
            console.log(`OTP sent to ${phone}: ${otp}`);
            return true;
        } catch (error) {
            console.error("Error sending OTP:", error);
            throw error;
        }
    }
}

module.exports = OTPService;