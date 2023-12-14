## AA functions

## Looking for relevant data row/columns
clean_aa_data = function(my_file){
  
  my_df = read.csv(my_file, fill = TRUE)
  
  ## Finding relevant columns/rows
  TN_col = which(my_df[which(my_df[1] == "METH"),] == "TN")
  
  # Forcing everything into lower case because the AA output is inconsistent with capitalisation
  nitrate_col = which(tolower(my_df[which(my_df[1] == "METH"),]) == "nitrate")
  ammonia_col = which(tolower(my_df[which(my_df[1] == "METH"),]) == "ammonia")
  tn_col = which(tolower(my_df[which(my_df[1] == "METH"),]) == "tn")
  
  # Checking which lines have data
  lines_check = c(length(ammonia_col)!=0, length(nitrate_col)!=0, length(tn_col)!=0)
  
  # Retrieving relevant data columns/rows. Slightly roundabout way to
  # ensure data type is correct
  my_df = my_df[my_df[,4] == "SAMP",] # column 4 is typically cup type
  ammonia = if(lines_check[1]){as.numeric(my_df[,ammonia_col])} else {NA}
  nitrate = if(lines_check[2]){as.numeric(my_df[,nitrate_col])} else {NA}
  tn = if(lines_check[3]){as.numeric(my_df[,tn_col])} else {NA}
  
  clean_df = data.frame(sample_id = my_df[,1],
                        ammonia,
                        nitrate,
                        tn)
  
  cat("Data retrieved for:", "\n",
      "Ammonia"[lines_check[1]], 
      "Nitrate"[lines_check[2]],
      "TN"[lines_check[3]], "\n")
  
  # Remove unused columns
  clean_df[,c(TRUE, lines_check)]
}

# Subtracting blanks
subtract_blanks = function(my_data, blank_pattern = "B", blank_rows = NA){
  blank_index = grep(blank_pattern, my_data[,1])
  
  if(!is.na(blank_rows[1])){
    blank_index = blank_rows
  }
  
  blanked_data = my_data
  
  if(ncol(blanked_data)==2){
    blanked_data[,-1] = blanked_data[,-1] - mean(blanked_data[blank_index,-1])
  } else {
    blanked_data[,-1] = apply(blanked_data[,-1], 2, function(x){
      x - mean(x[blank_index])
    })
  }
  
  blanked_data = blanked_data[-blank_index,]
  
  # Print a warning if this results in negative values
  if(sum(blanked_data<0)!= 0){
    warning("Average blank concentration was higher than in some samples","\n")
  }
  blanked_data
}

## clean_aa_data takes as input the path to the .csv file (converted from .SLK format)
## subtract_blanks assumes as input the dataframe produced by clean_aa_data
# subtract_blanks(my_data, blank_pattern = "B") # To auto detect blanks via a pattern
# subtract_blanks(my_data, blank_pattern = "BLANK") # To auto detect blanks via a pattern
