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

### Docker

The app includes a `Dockerfile` for containerized deployment:

```bash
# Build the image
docker build -t expense-tracker .

# Run the container
docker run -p 3000:3000 expense-tracker
```

### Environment Variables

For production, set the following environment variables:

```bash
RAILS_ENV=production
SECRET_KEY_BASE=<your-secret-key>
DATABASE_URL=postgres://user:pass@host:5432/expense_tracker_production
```

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
