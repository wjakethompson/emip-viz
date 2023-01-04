### EMIP Cover Submission
library(dplyr)
library(ggplot2)
library(tidyr)

# Simulate Data
set.seed(090416)

itemResponse <- function(x){
    rand <- runif(1, min = 0, max = 1)
    if(rand < x){
        response <- 1
    } else{
        response <- 0
    }
    response
}

num_stu <- 3000
num_stage <- 6
num_blocks <- 2
num_items <- 5

item_list <- list()
track <- 1
for(stage in 1:num_stage){
    for(block in 1:num_blocks){
        for(linkage in 1:5){
            for(item in 1:num_items){
                a <- rlnorm(1, meanlog = 0, sdlog = 0.5)
                
                if(linkage == 1){
                    bmean <- -1.5
                } else if(linkage == 2){
                    bmean <- -0.5
                } else if(linkage == 3){
                    bmean <- 0.5
                } else if(linkage == 4){
                    bmean <- 1.5
                } else{
                    bmean <- 2.5
                }
                
                b <- rnorm(1, mean = bmean, sd = 0.2)
                
                cur_item <- data.frame(Item_Number = track, Stage = stage, Block = block, Linkage = linkage, Item = item, a_param = a, b_param = b)
                item_list[[track]] <- cur_item
                track <- track + 1
            }
        }
    }
}
item_list <- do.call("rbind", item_list)
item_list <- item_list[-which(item_list$Stage == 1 & item_list$Linkage == 5),]
item_list$Item_Number <- 1:nrow(item_list)

theta <- rnorm(num_stu, c(rep(-1, num_stu/3), rep(0, num_stu/3), rep(2, num_stu/3)), 1)

cur_data <- list()
for(i in 1:length(theta)){
    stu_data <- data.frame(StuID = i, Grade = 99, State = "Simulation", Subject = "Sim", TestletNum = 1:num_stage, LL = NA, Complex = "Band 2")
    
    cur_theta <- theta[i]
    cur_linkage <- 3
    
    for(stg in 1:num_stage){
        stu_data[stg,"LL"] <- cur_linkage
        
        blk <- sample(1:2, 1)
        cur_items <- filter(item_list, Stage == stg, Block == blk, Linkage == cur_linkage)
        cur_items$prob_success <- 1 / (1 + exp(-(cur_items$a_param) * (cur_theta - cur_items$b_param)))
        cur_items$response <- sapply(cur_items$prob_success, itemResponse)
        
        # determine next linkage level
        pct_correct <- (sum(cur_items$response) / nrow(cur_items)) * 100
        if(pct_correct < 35){
            cur_linkage <- cur_linkage - 1
        } else if(pct_correct >= 80){
            cur_linkage <- cur_linkage + 1
        }
        if(cur_linkage > 5){
            cur_linkage <- 5
        } else if(cur_linkage < 1){
            cur_linkage <- 1
        }
    }
    cur_data[[i]] <- stu_data
}
cur_data <- do.call("rbind", cur_data)
save(cur_data, file = "EMIP_Data_Simulated.RData")

#########################################################################################
### Create graphic ######################################################################
#########################################################################################
#load("EMIP_Data.RData")
load("EMIP_Data_Simulated.RData")
library(dplyr)
library(ggplot2)
library(tidyr)

num_testlets <- max(cur_data$TestletNum)

trans_matrix <- data.frame(TestletNum = 1:num_testlets, IP = NA, DP = NA, PP = NA, "T" = NA, S = NA)
for(r in 1:nrow(trans_matrix)){
    for(c in 2:ncol(trans_matrix)){
        trans_matrix[r,c] <- length(which(cur_data$TestletNum == r & cur_data$LL == (c - 1)))
    }
}

# find different patterns & n for each pattern
stuIDs <- unique(cur_data$StuID)
patterns <- list()
for(s in 1:length(stuIDs)){
    stu_data <- filter(cur_data, StuID == stuIDs[s])
    pattern_row <- data.frame(id = stuIDs[s], num_testlet = nrow(stu_data), pattern = NA, stringsAsFactors = FALSE)
    pattern_row$pattern <- paste0("[", paste(stu_data$LL, collapse = ","), "]")
    patterns[[s]] <- pattern_row
}
patterns <- do.call("rbind", patterns)
patterns <- filter(patterns, num_testlet > 2)
pattern_count <- as.data.frame(table(patterns$pattern))
#pattern_count <- filter(pattern_count, Freq > 6)
pattern_count <- pattern_count %>%
    top_n(50, Freq)

AllPatterns <- list()
if(nrow(pattern_count) > 0){
    for(r in 1:nrow(pattern_count)){
        pattern_vec <- as.character(pattern_count[r,"Var1"])
        pattern_vec <- gsub("[[]", "", pattern_vec)
        pattern_vec <- gsub("[]]", "", pattern_vec)
        pattern_vec <- as.numeric(unlist(strsplit(pattern_vec, ",")))
        final_level <- pattern_vec[length(pattern_vec)]
        pattern_frame <- data.frame(TestletNum = 1:length(pattern_vec), LL = pattern_vec, pattern_id = r, final_LL = final_level, stringsAsFactors = FALSE)
        pattern_list <- list()
        new_id <- NULL
        for(f in 1:pattern_count[r,"Freq"]){
            pattern_list[[f]] <- pattern_frame
            new_id <- c(new_id, rep(f, length(pattern_vec)))
        }
        pattern_frame <- do.call("rbind", pattern_list)
        
        pattern_frame$line_id <- paste0(pattern_frame$pattern_id, "_", new_id)
        AllPatterns[[r]] <- pattern_frame
    }
}
AllPatterns <- do.call("rbind", AllPatterns)

# Plots
PlotData <- trans_matrix %>%
    gather("LL", "NumStu", 2:6)

PlotData$LL <- factor(PlotData$LL, levels = c("IP", "DP", "PP", "T", "S"))
PlotData$LL_Numeric <- as.numeric(PlotData$LL)
PlotData[which(PlotData$NumStu == 0),"NumStu"] <- NA
PlotData <- PlotData[complete.cases(PlotData),]

# Smoothed Lines
picname <- "EMIP_FullColor_Simulated.png"
png(picname, height = 8, width = 12, units = "in", res = 120)
suppressWarnings(
    print(
        ggplot() +
            geom_line(aes(x = AllPatterns$TestletNum, y = AllPatterns$LL, group = AllPatterns$line_id, color = factor(AllPatterns$final_LL)), stat = "smooth", method = "loess", alpha = 0.009, size = 1) +
            geom_point(aes(x = PlotData$TestletNum, y = PlotData$LL_Numeric, size = PlotData$NumStu), color = "black", alpha = 0.4) +
            scale_x_continuous(lim = c(1, num_testlets), breaks = seq(1, num_testlets, 1)) +
            scale_y_continuous(lim = c(0,6), breaks = seq(0,6,1), labels = c(0, "Initial\nPrecursor", "Distal\nPrecursor", "Proximal\nPrecursor", "Target", "Successor", 6)) +
            coord_cartesian(ylim = c(0.75, 5.25), xlim = c(0.75, max(AllPatterns$TestletNum, na.rm = TRUE) + 0.25)) +
            labs(x = "Testlet Number", y = "Linkage Level") +
            scale_size_area(name = "Number of\nStudents", limits = c(0, num_stu), max_size = 15, breaks = c(100, 250, seq(500, num_stu, 500))) +
            scale_color_manual(name = "Ending\nLinkage Level", values = c("firebrick", "darkorange2", "deepskyblue", "blue", "green"), labels = c("Initial\nPrecursor", "Distal\nPrecursor", "Proximal\nPrecursor", "Target", "Successor")) +
            guides(color = guide_legend(override.aes = list(alpha = 1))) +
            theme(legend.position = "bottom")
    )
)
dev.off()