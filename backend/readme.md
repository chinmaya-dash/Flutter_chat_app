# chatshare Backend

## Project Overview
This is the backend server for **chatshare**, a conversational assistant that helps users engage in meaningful chats, generate daily questions, and connect with contacts. The server is built with Node.js, Express.js, and PostgreSQL, using a clean and modular architecture.

## Setup Instructions

### Prerequisites
- Node.js (v14+)
- PostgreSQL (v12+)
- An OpenAI API Key (to generate AI-powered daily questions)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-repo-name.git
   cd your-repo-name
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   Create a `.env` file in the project root and configure it as follows:
   ```env
   PORT=6000
   OPENAI_API_KEY=your_openai_api_key
   JWT_SECRET=your_jwt_secret
   ```
   - Replace `username`, `password`, and `wori_db` with your PostgreSQL credentials and database name
   - Replace `your_openai_api_key` with the key obtained from OpenAI

4. **Set up the database**:
   Run the following SQL commands to create the necessary tables and columns:
   ```sql
   -- Users Table
   CREATE TABLE users (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       username VARCHAR(50) NOT NULL,
       email VARCHAR(100) UNIQUE NOT NULL,
       password VARCHAR(200) NOT NULL,
       profile_image TEXT DEFAULT 'https://via.placeholder.com/150'
   );

   -- Conversations Table
   CREATE TABLE conversations (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       participant_one UUID REFERENCES users(id),
       participant_two UUID REFERENCES users(id),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Messages Table
   CREATE TABLE messages (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       conversation_id UUID REFERENCES conversations(id),
       sender_id UUID REFERENCES users(id),
       content TEXT NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Contacts Table
   CREATE TABLE contacts (
       id SERIAL PRIMARY KEY,
       user_id UUID REFERENCES users(id),
       contact_id UUID REFERENCES users(id),
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       UNIQUE(user_id, contact_id)
   );
   ```

5. **Run the server**:
   Start the development server:
   ```bash
   npm run dev
   ```
   The server will run at `http://localhost:6000` by default.

## API Documentation

### Authentication Routes (`/auth`)

#### Register a new user
- **POST** `/register`
- **Body**:
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string"
  }
  ```

#### Log in a user
- **POST** `/login`
- **Body**:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```

### Conversations Routes (`/conversations`)

#### Fetch all conversations
- **GET** `/`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer <JWT_TOKEN>"
  }
  ```

#### Check or create conversation
- **POST** `/check-or-create`
- **Body**:
  ```json
  {
    "contactId": "UUID"
  }
  ```

#### Get daily question
- **GET** `/:id/daily-question`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer <JWT_TOKEN>"
  }
  ```

### Messages Routes (`/messages`)

#### Fetch conversation messages
- **GET** `/:conversationId`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer <JWT_TOKEN>"
  }
  ```

### Contacts Routes (`/contacts`)

#### Fetch all contacts
- **GET** `/`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer <JWT_TOKEN>"
  }
  ```

#### Add new contact
- **POST** `/`
- **Body**:
  ```json
  {
    "email": "string"
  }
  ```

#### Fetch recent contacts
- **GET** `/recent`
- **Headers**:
  ```json
  {
    "Authorization": "Bearer <JWT_TOKEN>"
  }
  ```

## Additional Notes

### Error Handling
- All error responses (4xx and 5xx status codes) contain an `error` key in the response body.

### Authorization
- All protected routes require a valid JWT token in the `Authorization` header.