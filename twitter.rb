require 'twitter'

class TwitterConnect

    def initialize()
        config = {
            :consumer_key => '5e0ZtD8Ar8qOpih52ljqq647Z',
            :consumer_secret => '5otIuyiETzis0QtI2rKmCtuCvyWNAhP4VDoPJZViQKQ2DakGub',
            :access_token =>  '836528282011062272-GqzwljW60TnOq5WYprXG6Qk035Uz8m4',
            :access_token_secret => 'jnAJVjAgtjGhRTXS5oMvpiDDTqqrIwHn52EAWCi6BCJgp'
            }

        @client = Twitter::REST::Client.new(config)
        @usernames = Array.new
        @tweet_text = Array.new
        @retweets = Array.new
    end
    @db = SQLite3::Database.new('useraccounts.sqlite')
    @db_orders =  SQLite3::Database.new('orders.sqlite')
    
    # finding the tweets containing @SignOffPizza
    def find_tweets 
        tweets = @client.mentions_timeline()
        most_recent = tweets.take(30)
        most_recent.each do |tweet|
            if(tweet.user.screen_name != 'SignOffPizza') then
                @usernames.push(tweet.user.screen_name)
                @tweet_text.push(tweet.text)
            end
           end
        end
        
        def get_usernames 
            return @usernames
        end

        def get_tweet_text
            return @tweet_text
        end

        def get_followers
            @user = @client.user('signoffpizza')
            return @user.followers_count
        end

        # Function for replying back to the costumer that the order has been received
        def reply
            tweets = @client.mentions_timeline()
            most_recent = tweets.take(30)
            most_recent.each do |tweet|
                client.update('Thank you! Your order has been received and is now being processed.', :in_reply_to_status_id => tweet.id )
            end
        end

        #function used to post a tweet
        def post_tweet
            @tweet_text = params[:tweet].strip
            @tweet_text.push(tweet.text)
        end

        #function used to follow people who tweet '#pizza'
        def follow 
            tweets = @client.mentions_timeline()
            most_recent = tweets.take(30)
            if @tweet_text.include? "#pizza"
                @client.follow(tweet.user.screen_name)
            end
        end

        def follow_user(username)
            @client.follow(username)
        end

        def unfollow_delete(username)
            @client.unfollow(username)
        end
            
        def unfollow
            orders = @db_orders.execute(
                'SELECT sender FROM orders')
            users = @db.execute(
                'SELECT username FROM info')
            users.each do |user|
                orders.each do |order|
                    ok = false
                    if user == order then
                        ok = true
                    end

                    end
                end
            end

end
        