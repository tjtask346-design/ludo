import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  playerId: string;
  name: string;
  coins: number;
  diamonds: number;
  level: number;
  xp: number;
  wins: number;
  losses: number;
}

const UserSchema: Schema = new Schema({
  playerId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  coins: { type: Number, default: 1000 },
  diamonds: { type: Number, default: 50 },
  level: { type: Number, default: 1 },
  xp: { type: Number, default: 0 },
  wins: { type: Number, default: 0 },
  losses: { type: Number, default: 0 }
}, { timestamps: true });

export const User = mongoose.model<IUser>('User', UserSchema);
