# 🚕 Ola Ride Booking Analytics

An end-to-end **Ola Ride Booking Data Analytics project** that analyzes ride booking data to uncover insights into booking performance, revenue, cancellations, vehicle types, customer behavior, locations, ratings, and demand patterns.

The project combines **Excel, SQL, Python, Pandas, Streamlit, and Plotly** to transform raw ride-booking data into an interactive analytics dashboard.

---

## 📊 Project Overview

This project analyzes Ola ride-booking data through a complete data analytics workflow:

**Raw Data → Data Cleaning → SQL Analysis → Python Analytics → Interactive Dashboard → Business Insights**

The objective is to understand ride-booking performance and identify patterns that can help improve:

* Booking success rates
* Revenue performance
* Customer experience
* Driver performance
* Cancellation management
* Vehicle utilization
* Location-level operations
* Demand forecasting and planning

---

## ✨ Key Features

### 📈 Executive Dashboard

The Streamlit dashboard provides important KPIs including:

* Total Bookings
* Successful Rides
* Success Rate
* Cancelled Rides
* Cancellation Rate
* Total Revenue
* Average Booking Value
* Average Ride Distance
* Average Ride Duration
* Average Driver Rating
* Average Customer Rating

The dashboard dynamically updates these metrics based on the selected filters.

### 🎛️ Interactive Filters

Users can filter the analysis by:

* Booking Date
* Vehicle Type
* Booking Status
* Payment Method
* Pickup Location

This makes it possible to investigate specific segments of the business.

### 📊 Data Visualizations

The dashboard contains multiple interactive visualizations:

* Booking trend by date
* Revenue trend
* Booking-status distribution
* Revenue by vehicle type
* Payment-method distribution
* Cancellation reasons
* Cancellation rate by vehicle type
* Top pickup locations
* Top drop locations
* Demand heatmap by day and hour
* Driver rating distribution
* Customer rating distribution
* Average ratings by vehicle type
* Repeat vs. one-time customers

---

## 🧩 Project Structure

```text
ola-dashboard-project/
│
├── app.py
│   └── Streamlit interactive dashboard
│
├── ola_bookings_raw.csv
│   └── Original/raw booking dataset
│
├── ola_bookings_cleaned.csv
│   └── Cleaned dataset used for analysis
│
├── Ola_Data_Cleaning.xlsx
│   └── Excel-based data cleaning and preparation
│
├── ola_sql_analysis.sql
│   └── SQL database setup and analytical queries
│
├── Ola_Ride_Booking_Analytics_Project.docx
│   └── Project documentation/report
│
└── requirements.txt
    └── Python dependencies
```

The repository contains one main application file (`app.py`) along with the raw and cleaned datasets, Excel cleaning stage, SQL analysis, and project report.

---

## 🛠️ Technologies Used

| Technology    | Purpose                                 |
| ------------- | --------------------------------------- |
| **Python**    | Data analysis and dashboard development |
| **Pandas**    | Data cleaning and transformation        |
| **NumPy**     | Numerical operations                    |
| **Plotly**    | Interactive charts and visualizations   |
| **Streamlit** | Interactive web dashboard               |
| **SQL**       | Data querying and business analysis     |
| **Excel**     | Initial data cleaning and preparation   |

The current Python dependency file specifies Streamlit, Pandas, and Plotly.

---

## 🗃️ Dataset

The cleaned dataset contains ride-booking information including fields such as:

* Booking ID
* Booking Date
* Booking Time
* Customer ID
* Driver ID
* Vehicle Type
* Pickup Location
* Drop Location
* Ride Distance
* Booking Status
* Cancellation Reason
* Payment Method
* Booking Value
* Driver Rating
* Customer Rating
* Ride Duration
* Booking Day
* Booking Month
* Booking Week
* Weekend Indicator
* Booking Hour
* Cancellation Indicator
* Revenue per KM
* Validation Flag

These fields are also represented in the SQL table structure used by the project.

---

## 🧹 Data Cleaning

The project follows a dedicated data-cleaning stage before performing SQL and dashboard analysis.

The cleaned CSV is the primary data source for the Streamlit dashboard and SQL analysis.

The dashboard automatically converts the booking date to a datetime format and converts relevant numerical columns such as ride distance, booking value, ratings, ride duration, revenue per kilometre, and booking hour into numeric values.

---

## 🗄️ SQL Analysis

The SQL analysis script creates an `ola_analytics` database and an `ola_bookings` table for analytical queries.

The SQL workflow includes:

### 1. Booking Performance

* Total bookings
* Successful bookings
* Cancelled bookings
* Cancellation rate
* Success rate

### 2. Revenue Analysis

* Total revenue
* Average booking value
* Revenue by vehicle type
* Revenue per kilometre

### 3. Ride Analysis

* Average ride distance
* Average ride duration
* Distance distribution

### 4. Vehicle Analysis

* Most popular vehicle types
* Successful rides by vehicle
* Cancellation rate by vehicle
* Revenue by vehicle
* Driver ratings by vehicle

### 5. Location Analysis

* Top pickup locations
* Top drop locations
* Highest-revenue pickup locations
* High-demand locations with high cancellation rates

### 6. Payment Analysis

* Payment-method distribution
* Percentage of rides by payment method
* Revenue by payment method

### 7. Rating Analysis

* Average driver rating
* Average customer rating
* Ratings by vehicle type
* Low-rated rides

### 8. Time-Based Analysis

* Daily booking trends
* Hourly demand
* Day-of-week patterns
* Weekend vs. weekday performance

The SQL script is written for **MySQL 8+ / PostgreSQL 13+**, with notes for database-specific loading/date syntax.

---

## 📱 Streamlit Dashboard

The dashboard is implemented in `app.py`.

Run the application using:

```bash
streamlit run app.py
```

The application automatically looks for:

```text
ola_bookings_cleaned.csv
```

in the same directory.

If the file is not found, the dashboard provides a CSV file-upload option instead.

---

## 🚀 Installation & Setup

### 1. Clone the repository

```bash
git clone https://github.com/adityakumar632-web/ola-dashboard-project.git
```

### 2. Navigate into the project

```bash
cd ola-dashboard-project
```

### 3. Create a virtual environment

```bash
python -m venv venv
```

Activate it:

**Windows**

```bash
venv\Scripts\activate
```

**macOS / Linux**

```bash
source venv/bin/activate
```

### 4. Install dependencies

```bash
pip install -r requirements.txt
```

### 5. Run the dashboard

```bash
streamlit run app.py
```

The application will open in your browser.

---

## 🔍 Business Questions Answered

This project can be used to answer questions such as:

1. How many rides were booked?
2. What percentage of bookings were successful?
3. What is the overall cancellation rate?
4. Which vehicle type generates the most revenue?
5. Which vehicle type receives the most bookings?
6. Which locations have the highest booking demand?
7. What are the major reasons for cancellations?
8. Which vehicle types have the highest cancellation rates?
9. Which payment methods are most frequently used?
10. What is the average ride distance?
11. What is the average ride duration?
12. Which vehicle types have the best ratings?
13. When is ride demand highest?
14. Which locations have high demand but poor fulfillment?
15. What proportion of customers are repeat customers?
16. Which rides have unusually low driver ratings?

---

## 💡 Key Analytical Areas

### Revenue Performance

Revenue is calculated from successful rides, allowing the analysis to distinguish actual ride revenue from cancelled bookings. Revenue can then be compared across vehicle types, locations, and payment methods.

### Cancellation Analysis

Cancellation analysis identifies the major cancellation reasons and compares cancellation rates across vehicle categories and locations.

This can help identify operational areas where fulfillment needs improvement.

### Location Analysis

Pickup and drop locations are ranked based on booking volume. The project also identifies high-demand pickup locations with comparatively high cancellation rates, which can highlight potential operational problem areas.

### Demand Analysis

The dashboard uses a day-of-week × hour-of-day heatmap to visualize when booking demand is concentrated.

### Customer & Rating Analysis

The project analyzes both driver and customer ratings and compares rating performance across vehicle types. It also distinguishes between repeat and one-time customers.

---

## 📊 Dashboard Pages

### 1. 📈 Executive Overview

Provides a high-level view of:

* Booking volume
* Revenue
* Booking status
* Vehicle performance
* Payment methods
* Daily trends

### 2. 📍 Cancellations & Locations

Focuses on:

* Cancellation reasons
* Vehicle cancellation rates
* Top pickup locations
* Top drop locations
* Demand heatmap

### 3. ⭐ Ratings & Customers

Focuses on:

* Driver ratings
* Customer ratings
* Ratings by vehicle type
* Repeat vs. one-time customers

These three sections are implemented as Streamlit tabs in the dashboard.

---

## 🏗️ Data Analytics Workflow

```text
                 ┌────────────────────┐
                 │   Raw Ola Dataset  │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │   Excel Cleaning   │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │ Cleaned CSV Dataset│
                 └─────────┬──────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
      ┌───────────────┐         ┌────────────────┐
      │ SQL Analysis  │         │ Python / Pandas│
      └───────┬───────┘         └────────┬───────┘
              │                          │
              └────────────┬─────────────┘
                           ▼
                  ┌──────────────────┐
                  │ Streamlit +      │
                  │ Plotly Dashboard │
                  └────────┬─────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ Business Insights│
                  └──────────────────┘
```

---

## 📌 Example KPIs

The dashboard calculates KPIs dynamically from the selected dataset and filters:

```text
Total Bookings
Successful Rides
Cancellation Rate
Total Revenue
Average Booking Value
Average Ride Distance
Average Ride Duration
Average Driver Rating
Average Customer Rating
```

The implementation calculates revenue from successful rides and derives success/cancellation rates from the filtered booking data.

---

## 🔮 Future Improvements

Possible improvements for future versions include:

* [ ] Add a live deployment using Streamlit Community Cloud
* [ ] Add downloadable filtered datasets
* [ ] Add monthly and weekly revenue forecasting
* [ ] Add customer segmentation
* [ ] Add driver-level performance analysis
* [ ] Add route-level profitability analysis
* [ ] Add geographical maps for pickup/drop locations
* [ ] Add predictive cancellation modeling
* [ ] Add demand forecasting
* [ ] Add automated data refresh
* [ ] Add database connectivity instead of relying only on CSV
* [ ] Add automated data-quality checks
* [ ] Add authentication for dashboard access

---

## 📚 Skills Demonstrated

This project demonstrates practical experience with:

* Data Cleaning
* Exploratory Data Analysis
* SQL
* Python
* Pandas
* NumPy
* Data Visualization
* Plotly
* Streamlit
* KPI Development
* Business Analytics
* Customer Analytics
* Revenue Analytics
* Operational Analytics
* Dashboard Development

---

## 👨‍💻 Author

**Aditya Kumar**

GitHub:
https://github.com/adityakumar632-web

---

## ⭐ Support

If you find this project useful, consider giving the repository a ⭐ on GitHub.

---

## 📄 License

No explicit license is currently provided in the repository. If you intend others to reuse, modify, or distribute this project, consider adding an appropriate open-source license.
