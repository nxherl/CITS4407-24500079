cleaned=$(cat "$1" | tr ';' '\t' | tr -d '\r' | sed 's/\([0-9]\),\([0-9]\)/\1.\2/g' | tr -cd '\0-\177')
header=$(echo "$cleaned" | head -n 1)
data=$(echo "$cleaned" | tail -n +2)

# Get highest value from first column
max_id=$(echo "$cleaned" | cut -f1 | grep -E '^[0-9]+$' | sort -n | tail -n 1 )
next_id=$((max_id + 1))

# Process each line in the cleaned data
final=$(echo "$data" | while IFS=$'\t' read -r first_column rest; do
    # If first column is not number then add next_id. Else print as is.
    if [[ ! "$first_column" =~ ^[0-9]+$ ]]; then
        echo -e "${next_id}\t$first_column\t$rest"
        next_id=$((next_id + 1))
    else
        echo -e "$first_column\t$rest"
    fi
done)

# Extract year_column (third column) and rating_column (ninth column)
year_column=$(echo "$final" | cut -f3)
rating_column=$(echo "$final" | cut -f9)

# Initialize variables for sum and count for year_column
sum_year=0
count_year=0

# Loop through each value in the year_column and calculate the sum and count
while IFS=$'\n' read -r year; do
    # Check if the value is a valid number
    if [[ "$year" =~ ^[0-9]+$ ]]; then
        sum_year=$((sum_year + year))  # Add the year to sum
        count_year=$((count_year + 1))  # Increment the count
    fi
done <<< "$year_column"

# Calculate the average (mean) for year_column
if [[ $count_year -gt 0 ]]; then
    means_year=$(echo "scale=6; $sum_year / $count_year" | bc)  # Calculate and store the average
else
    means_year=0  # In case of no valid years, set mean to 0
fi

# Initialize variables for sum and count for rating_column
sum_rating=0
count_rating=0

# Loop through each value in the rating_column and calculate the sum and count
while IFS=$'\n' read -r rating; do
    # Check if the value is a valid number
    if [[ "$rating" =~ ^[0-9.]+$ ]]; then
        sum_rating=$(echo "$sum_rating + $rating" | bc)  # Add the rating to sum
        count_rating=$((count_rating + 1))  # Increment the count
    fi
done <<< "$rating_column"

# Calculate the average (mean) for rating_column
if [[ $count_rating -gt 0 ]]; then
    means_rating=$(echo "scale=6; $sum_rating / $count_rating" | bc)  # Calculate and store the average
else
    means_rating=0  # In case of no valid ratings, set mean to 0
fi

# Output the mean values
echo "The mean of the year_column is: $means_year"
echo "The mean of the rating_column is: $means_rating"
