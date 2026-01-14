# ExpenseTracker

A personal expense tracking application built with Ruby on Rails 8, designed for couples to manage and track their shared expenses.

![Ruby](https://img.shields.io/badge/Ruby-3.4+-red)
![Rails](https://img.shields.io/badge/Rails-8.0+-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-4.0-blue)

## Features

- 🔐 **User Authentication** - Secure login with Devise (email + password)
- 💰 **Expense Management** - Full CRUD operations for expenses
- 📊 **Dashboard** - Monthly overview with category breakdown
- 🔍 **Filtering** - Filter expenses by month and who spent them
- 📱 **Responsive Design** - Mobile-friendly dark theme UI
- 👫 **Multi-user Support** - Track expenses for both partners

## Tech Stack

- **Ruby** 3.4+
- **Rails** 8.0+
- **PostgreSQL** 15+
- **Tailwind CSS** 4.x
- **Hotwire** (Turbo + Stimulus)
- **Devise** for authentication

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.4+ (use `rbenv` or `rvm`)
- PostgreSQL 15+
- Node.js (for Tailwind CSS compilation)
- Git

### Installing Ruby with rbenv (macOS)

```bash
# Install rbenv if not already installed
brew install rbenv ruby-build

# Install Ruby 3.4
rbenv install 3.4.5
rbenv global 3.4.5

# Verify installation
ruby --version
```

### Installing PostgreSQL (macOS)

```bash
# Using Homebrew
brew install postgresql@15
brew services start postgresql@15
```

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd expense-tracker-app
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install
```

### 3. Database Setup

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# Seed the database with sample data
rails db:seed
```

### 4. Start the Development Server

```bash
# This starts both the Rails server and Tailwind CSS watcher
bin/dev
```

The application will be available at [http://localhost:3000](http://localhost:3000)

## Default Login Credentials

After running `rails db:seed`, you can log in with:

| User    | Email              | Password    |
|---------|-------------------|-------------|
| Husband | john@example.com  | password123 |
| Wife    | jane@example.com  | password123 |

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── dashboard_controller.rb    # Main dashboard with filters
│   └── expenses_controller.rb     # CRUD for expenses
├── models/
│   ├── expense.rb                 # Expense model with validations
│   └── user.rb                    # User model with Devise
├── views/
│   ├── dashboard/
│   │   └── index.html.erb         # Dashboard view
│   ├── expenses/
│   │   ├── _form.html.erb         # Expense form partial
│   │   ├── new.html.erb           # New expense page
│   │   ├── edit.html.erb          # Edit expense page
│   │   └── show.html.erb          # Expense details
│   ├── layouts/
│   │   ├── application.html.erb   # Main layout
│   │   ├── _navbar.html.erb       # Navigation bar
│   │   └── _footer.html.erb       # Footer
│   └── devise/                    # Styled Devise views
└── assets/
    └── tailwind/
        └── application.css        # Tailwind CSS with custom theme
```

## Data Model

### User
- `name` (string) - User's display name
- `email` (string) - Login email
- `encrypted_password` (string) - Devise password

### Expense
- `amount` (decimal) - Expense amount
- `spent_by` (enum) - Who spent: `self_expense` or `wife`
- `category` (string) - Expense category
- `note` (text) - Optional description
- `spent_on` (date) - Date of expense
- `user_id` (references) - Owner of the expense

### Predefined Categories
- Groceries
- Rent
- Travel
- Shopping
- Bills
- Other (for custom entries)

## Key Features Explained

### Authorization
Each user can only see and manage their own expenses. This is enforced at the controller level by scoping all queries to `current_user.expenses`.

### Filtering
The dashboard supports filtering by:
- **Month**: Use the month picker to view expenses for any month
- **Spent By**: Filter by "Self" or "Wife" expenses

### Dashboard Stats
- Monthly total spending
- Number of transactions
- Breakdown by who spent (Self vs Wife)
- Category-wise spending summary

## Development

### Running Tests

```bash
# Run the test suite
rails test
```

### Linting

```bash
# Run RuboCop
bin/rubocop
```

### Security Audit

```bash
# Check for security vulnerabilities
bin/bundler-audit
bin/brakeman
```

## Deployment

### Deploy to Render (Recommended)

This app is configured for easy deployment to [Render](https://render.com/).

#### Option 1: One-Click Deploy with Blueprint

1. Push your code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Click **New** → **Blueprint**
4. Connect your GitHub repository
5. Render will automatically detect the `render.yaml` file and set up:
   - A web service for the Rails app
   - A PostgreSQL database

#### Option 2: Manual Setup

1. **Create a PostgreSQL Database:**
   - Go to Render Dashboard → New → PostgreSQL
   - Name: `expense-tracker-db`
   - Plan: Free
   - Click "Create Database"

2. **Create a Web Service:**
   - Go to Render Dashboard → New → Web Service
   - Connect your GitHub repository
   - Configure:
     - **Name:** `expense-tracker`
     - **Runtime:** Ruby
     - **Build Command:** `./bin/render-build.sh`
     - **Start Command:** `bundle exec puma -C config/puma.rb`

3. **Set Environment Variables:**
   - `DATABASE_URL`: (Auto-linked from your PostgreSQL database)
   - `RAILS_MASTER_KEY`: (Copy from `config/master.key` in your local project)
   - `RAILS_ENV`: `production`
   - `RAILS_LOG_TO_STDOUT`: `true`
   - `RAILS_SERVE_STATIC_FILES`: `true`

4. **Deploy:**
   - Click "Create Web Service"
   - Render will automatically build and deploy your app

#### Adding the Master Key

The `RAILS_MASTER_KEY` is required to decrypt Rails credentials in production:

```bash
# View your master key locally
cat config/master.key
```

Copy this value and add it as an environment variable in Render.

#### Seeding Production Data

After the first deploy, you can seed the database by running:

```bash
# In Render Dashboard, go to your web service → Shell
bundle exec rails db:seed
```

Or uncomment the seed lines in `bin/render-build.sh` for automatic seeding.

### Docker Deployment

The app includes a `Dockerfile` for containerized deployment:

```bash
# Build the image
docker build -t expense-tracker .

# Run the container
docker run -p 3000:3000 expense-tracker
```

### Environment Variables

For production, the following environment variables are used:

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `RAILS_MASTER_KEY` | Key to decrypt credentials | Yes |
| `RAILS_ENV` | Set to `production` | Yes |
| `RAILS_LOG_TO_STDOUT` | Enable logging to stdout | Yes |
| `RAILS_SERVE_STATIC_FILES` | Serve static assets | Yes |
| `RENDER_EXTERNAL_URL` | Auto-set by Render | Auto |
| `RENDER_EXTERNAL_HOSTNAME` | Auto-set by Render | Auto |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open-source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Ruby on Rails](https://rubyonrails.org/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Devise](https://github.com/heartcombo/devise)
- [Hotwire](https://hotwired.dev/)
- [Render](https://render.com/)
