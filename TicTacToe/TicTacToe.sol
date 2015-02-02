contract TicTacToe
{
    struct Game
    {
        uint balance;
        uint turn; 
        address opposition;
        uint time_limit;
        mapping(uint => mapping(uint => uint)) board;
    }
    
    mapping (address => Game) games;
    
    function start()
    {
        Game g = games[msg.sender];
        if(msg.value > 0
        && g.balance == 0)
        {
            clear(msg.sender);
            g.balance += msg.value;
        }
    }
    
    function join(address host)
    {
        Game g = games[host];
        if(msg.value > 0
        && g.opposition == 0
        && msg.sender != host)
        {
            g.balance += msg.value;
            g.opposition = msg.sender;
        }
    }
    
    function play(address host, uint row, uint column)
    {
        Game g = games[host];
        
        uint8 player = 2;
        if(msg.sender == host)
            player = 1;
           
        if(g.balance > 0 && g.opposition != 0
        && row >= 0 && row < 3 && column >= 0 && column < 3
        && g.board[row][column] == 0
        && (g.time_limit == 0 || block.timestamp <= g.time_limit)
        && g.turn != player)
        {
            g.board[row][column] = player;
            
            if(is_full(host))
            {
                host.send(g.balance/2);
                g.opposition.send(g.balance/2);
                g.balance = 0;
                clear(host);
                return;
            }
            
            if(is_winner(host, player))
            {
                if(player == 1)
                    host.send(g.balance);
                else
                    g.opposition.send(g.balance);
                
                g.balance = 0;
                clear(host);
                return;
            }
                        
            g.turn = player;
            g.time_limit = block.timestamp + (60);
        }
    }
    
    function claim_reward(address host) returns (bool retVal)
    {
        Game g = games[host];
        
        if(g.opposition != 0 
        && g.balance > 0 
        && block.timestamp > g.time_limit)
        {
            if(g.turn == 2)
                host.send(g.balance);
            else
                g.opposition.send(g.balance);
                
            g.balance = 0;
            clear(host);
        }
    }
    
    function is_winner(address host, uint player) returns (bool winner)
    {
        Game g = games[host];
        for(uint r; r < 3; r++)
            if(g.board[r][0] == player
            && g.board[r][1] == player
            && g.board[r][2] == player)
                return true;
                
        for(uint c; c < 3; c++)
            if(g.board[0][c] == player
            && g.board[1][c] == player
            && g.board[2][c] == player)
                return true;
            
        if((g.board[0][0] == player
        && g.board[1][1] == player
        && g.board[2][2] == player)
        || (g.board[0][2] == player
        && g.board[1][1] == player
        && g.board[2][0] == player)
        || (g.turn == player 
        && block.timestamp >= g.time_limit))
            return true;
    }
    
    function is_full(address host) returns (bool retVal)
    {
        Game g = games[host];
        uint count = 0;
        for(uint r; r < 3; r++)
            for(uint c; c < 3; c++)
                if(g.board[r][c] > 0)
                    count++;
        if(count >= 9)
            return true;
    }
    
    function clear(address host)
    {
        Game g = games[host];
        if(g.balance == 0)
        {
            g.turn = 1;
            g.opposition = 0;
            g.time_limit = 0;
            
            for(uint r; r < 3; r++)
                for(uint c; c < 3; c++)
                    g.board[r][c] = 0;
        }
    }
    
    function get_state(address host) returns (uint o_balance, address o_opposition,
    uint o_timelimit, uint o_turn, uint orow1, uint orow2, uint orow3)
    {
        Game g = games[host];

        o_balance = g.balance;
        o_opposition = g.opposition;
        o_timelimit = g.time_limit;
        o_turn = g.turn;
        orow1 = (100 * (g.board[0][0] + 1)) 
        + (10 * (g.board[0][1] + 1)) + (g.board[0][2] + 1);
        orow2 = (100 * (g.board[1][0] + 1)) 
        + (10 * (g.board[1][1] + 1)) + (g.board[1][2] + 1);
        orow3 = (100 * (g.board[2][0] + 1)) 
        + (10 * (g.board[2][1] + 1)) + (g.board[2][2] + 1);
    }
}
