import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import pool from '../models/db';
import jwt from 'jsonwebtoken';
import { match } from 'assert';

const SALT_ROUNDS = 10;
const JWT_SECRET = process.env.JWT_SECRET || 'chatsharesecretkey';
const randomImages = [
    'https://img.freepik.com/free-photo/cute-cat-studio_23-2150932375.jpg?semt=ais_hybrid',
    'https://img.freepik.com/premium-photo/cute-cate-vector-design_780593-3.jpg?semt=ais_hybrid',
    'https://img.freepik.com/free-photo/christmas-pet-background-illustration_23-2151847693.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxSmyTnqOsoHay-NiDT-Zi4iorzBYucTpvmw&s',
    'https://img.freepik.com/premium-vector/cute-cat-cartoon-sitting_194935-99.jpg',
    'https://img.freepik.com/premium-photo/hipster-cute-pop-art-cat-illustration-hand-drawn_739548-370.jpg'
]

export const register = async(req: Request, res: Response) => {
    const {username, email, password} = req.body;
    try {
        // const { username, email, password } = req.body;
        const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
        const randomImage: string = randomImages[Math.floor(Math.random() * randomImages.length)];        // Insert user into DB
        // console.log(username,email,password);
        const result = await pool.query(
            `INSERT INTO users (username, email, password, profile_image) 
             VALUES ($1, $2, $3, $4) 
             RETURNING *;`,
            [username, email, hashedPassword, randomImages]
        );
        // console.log(result);
        
        const user = result.rows[0];
        // res.json(result);
        res.status(201).json({ message: 'User Registered Successfully', user });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Failed to register user' });
    }    
}

export const login = async(req: Request, res: Response): Promise<any> => {
    const {email, password} = req.body;
    try{
        const result = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email]
        );
        const user = result.rows[0];
        if(!user) return res.status(404).json({error: 'User not found'});

        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch) return res.status(400).json({error: 'Invalid credentials'});

        const token = jwt.sign({id: user.id}, JWT_SECRET, {expiresIn: '10h'});

        let finalResult = {...user, token}
        res.json({user: finalResult});
    } catch (error) {
        res.status(500).json({error: 'Failed to log in'});
    }
}