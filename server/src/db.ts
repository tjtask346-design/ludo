import mongoose from 'mongoose';

export async function connectDB() {
  try {
    const uri = process.env.MONGODB_URI;
    if (!uri) {
      console.warn("MONGODB_URI not found in environment. Running in-memory only.");
      return;
    }
    await mongoose.connect(uri);
    console.log("✓ Connected to MongoDB Atlas");
  } catch (error) {
    console.error("✗ MongoDB connection error:", error);
  }
}
