class ActorsController < ApplicationController
    #skip_before_action :verify_authenticity_token
  
  
    # Returning the actor records ordered by the total number of events`
   # The service return the JSON array of 
   # all the actors sorted by the total number of associated events with each actor in descending order by 
   # the GET request at /actors 
   #
   # == Parameters: 
   #
   # == Returns: JSON
   #      {
   #        "id":3648056,
   #        "login":"ysims",
   #        "avatar_url":"https://avatars.com/modified2"
   #      }
   #   If completed The HTTP response code should be 200
   #   If actor does not exist The HTTP response code should be 400
   def index
           begin
             @actor =  Actor
             .select("actors.id, actors.login, actors.avatar_url")
             .joins(:events)
             .group("actors.id, actors.login, actors.avatar_url")
             .order("count(*) DESC, max(events.created_at) DESC, actors.login")
             render   json: @actor.to_json 
           rescue => exception
             @actor = nil
             head 400      
           end
    end  
   
   
   # Returning the actor records ordered by the maximum streak`
   # The service return the JSON array of 
   # all the actors sorted by the maximum streak 
   # the GET request at /actors 
   #(i.e., the total number of consecutive days actor has pushed an event to the system) in descending order by the GET request at /actors/streak. 
   #If there are more than one actors with the same maximum streak, 
   #then order them by the timestamp of the latest event in the descending order. 
   #If more than one actors have the same timestamp for the latest event, 
   #then order them by the alphabetical order of login. 
   #
   # == Parameters: 
   #
   # == Returns: JSON
   #     [ {
   #        "id":3648056,
   #        "login":"ysims",
   #        "avatar_url":"https://avatars.com/modified2"
   #      }]
   #   If completed The HTTP response code should be 200
   #   If actor does not exist The HTTP response code should be 400
         def streak
           begin
         #   @actor =  ActiveRecord::Base.connection.exec_query("SELECT actors.id, actors.login, actors.avatar_url FROM actors INNER JOIN (SELECT actor_id,  grp, MAX(grp) created_at,  count(grp) qtd_days FROM ( SELECT actor_id, ROW_NUMBER() OVER (ORDER BY datetime(created_at, 'start of day') ) AS rn, date(datetime(created_at, 'start of day'), '-' || ( ROW_NUMBER() OVER (partition by actor_id ORDER BY datetime(created_at, 'start of day') ) )  || ' day')   AS grp,  datetime(created_at, 'start of day') created_at FROM  (SELECT DISTINCT  actor_id, datetime(created_at, 'start of day') created_at FROM events)) GROUP BY actor_id, grp ORDER BY qtd_days desc, created_at, actor_id ) ev ON ev.actor_id = actors.id  INNER JOIN events ON events.actor_id = actors.id  GROUP BY actors.id, actors.login, actors.avatar_url  ORDER BY MAX(ev.qtd_days) DESC, max(events.created_at) DESC, actors.login ASC")
#            @actor =  ActiveRecord::Base.connection.exec_query("SELECT actors.id, actors.login, actors.avatar_url FROM actors  INNER JOIN events ON events.actor_id = actors.id  INNER JOIN ( SELECT  actor_id,  max(count) qtd_days FROM ( SELECT  e1.actor_id, (count(*)  +1) as count FROM ( SELECT DISTINCT actor_id, date(created_at) created_at from events) e1 LEFT JOIN (SELECT DISTINCT actor_id, date(created_at) created_at from events) e2  ON e1.actor_id = e2.actor_id AND e1.created_at = date(e2.created_at, '-1 day') group by  e1.actor_id) group by  actor_id ) ev ON ev.actor_id = actors.id  GROUP BY actors.id, actors.login, actors.avatar_url  ORDER BY COALESCE(MAX(ev.qtd_days),0) DESC, max(events.created_at) DESC, actors.login ASC")
             #render   json: @actor.to_json 
             if @actor.nil?
                render json: JSON.parse( JSON.generate([])), :status => 200
             else
                binding.pry
                render json: @actor.to_a, :status => 200
             end
           rescue => exception
            # @actor = nil
             #head 400     
             puts "exception.message: #{exception.message}"
             render json: JSON.parse(JSON.generate([])), :status => 200            end
         end
         
   
          # Returning the event records filtered by the actor ID`
   # The service return the JSON array of all the events 
   # by the actor ID by the GET request at /events/actors/{actorID}. 
   #
   # == Parameters: actorID
   #
   # == Returns:
   #   If completed The HTTP response code should be 200
   #   If actor does not exist The HTTP response code should be 404
    # == Returns: JSON
    # [
    #   {
    #     "id":3822562012,
    #     "type":"PushEvent",
    #     "actor":{
    #       "id":2222918,
    #       "login":"xnguyen",
    #       "avatar_url":"https://avatars.com/2222918"
    #     },
    #     "repo":{
    #       "id":425512,
    #       "name":"cohenjacqueline/quam-autem-suscipit",
    #       "url":"https://github.com/cohenjacqueline/quam-autem-suscipit"
    #     },
    #     "created_at":"2015-07-15 15:13:31"
    #   }
    # ]
   def show
    if !params[:id].nil?
       begin
         @event =  Event.select("events.id,        type, strftime('%Y-%m-%d %H:%M:%S', created_at) xpto,repo_id, actor_id").joins(:repo).joins(:actor).where("actors.id = #{params[:id]}")
         #@event =  Event.select("events.id, type, strftime('%Y-%m-%d %H:%M:%S', created_at) xpto, repo_id, actor_id").includes(:repo).includes(:actor).where(actors: {id: params[:id]})
         # @event =  Event.includes(:repo).includes(:actor).where(actors: {id: params[:id]})
       rescue => exception
         @event =  nil
       end 
       if !@event.nil? && !@event.first.nil? 
        render json: ((@event.to_json(except:[:actor_id, :repo_id],include:[ :actor, :repo ]).gsub! 'xpto', 'created_at')), :status => 200
        # render json: @event.to_json(except:[:actor_id],include:[ :actor, repo: {except: [ :event_id]} ]), :status => 200
       else
        #head 404
        #render json: [], :status => 404
        render json: JSON.parse( JSON.generate({})), :status => 404
        # render json: JSON.parse( JSON.generate([])), :status => 404, :body => []
       end
   else
     #head 500
     #render json: [], :status => 404
     render json: JSON.parse( JSON.generate({})), :status => 404
  #   render json: JSON.parse( JSON.generate([])), :status => 404, :body => []
   end  
  
  end  
  
    # Updating the avatar URL of the actor`
   # The service return the JSON array of 
   # all the actors sorted by the total number of associated events with each actor in descending order by 
   # the GET request at /actors 
   #
   # == Parameters: JSON
   #      {
   #        "id":3648056,
   #        "login":"ysims",
   #        "avatar_url":"https://avatars.com/modified2"
   #      }
   #
   # == Returns: 
   #   If completed The HTTP response code should be 200
   #   if there are other fields being updated for the actor then the HTTP response code should be 400
   #   If does not exist then the response code should be 404
    def update
        begin
          json_parsed = params
          if !json_parsed.nil? && !json_parsed[:id].nil?
            @actor = Actor.find(json_parsed[:id])
  
  
            if @actor.nil?
              #head 404
              render json: JSON.parse( JSON.generate({})), :status => 404
             elsif @actor.login == json_parsed[:login] 
              @actor.update(avatar_url: json_parsed[:avatar_url])
              #head 200
              render json: JSON.parse( JSON.generate({})), :status => 200
             else  
              #head 400
              render json: JSON.parse( JSON.generate({})), :status => 400
             end
            else
              #head 400
              render json: JSON.parse( JSON.generate({})), :status => 400
            end  
        rescue => exception
            #head 404
            render json: JSON.parse( JSON.generate({})), :status => 404
          end
    end 
    
   
   end