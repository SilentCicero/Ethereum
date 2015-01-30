contract TicTacToe
{
    struct Board
    {
        mapping(uint => mapping(uint => uint)) positions;
    }
    
    struct Game
    {
        uint balance; // The collective amount at stake
        uint turn; // Always the opposite of present players turn
        address opposition; // The opposition player
        uint time_limit; // The time the next player has until they default
        Board board; // The actual board
    }
    
    mapping (address => Game) games;
    
    function start()
    {
        if(msg.value > 0)
        {
            Game g = games[msg.sender];
            clear(msg.sender);
            g.balance = msg.value;
        }
    }
    
    function join(address host)
    {
        Game g = games[host];
        if(msg.value > 0
        && msg.sender != host)
        {
            g.balance += msg.value;
            g.opposition = msg.sender;
        }
    }
    
    function play(address host, uint row, uint column)
    {
        Game g = games[host];
        if(g.balance > 0 
        && g.opposition != 0
        && row >= 0 && row < 3 && column >= 0 && column < 3
        && g.board.positions[row][column] == 0)
        {
            uint player = 2;
            if(msg.sender == host)
                player = 1;
               
            if(player == g.turn || block.timestamp > g.time_limit)
                return;
                
            g.board.positions[row][column] = player;
            if(is_winner(host, player))
            {
                if(player == 1)
                    host.send(g.balance);
                else
                    g.opposition.send(g.balance);
                    
                g.balance = 0;
                return;
            }
            else
            {
                if(is_full(host))
                {
                    host.send(g.balance/2);
                    g.opposition.send(g.balance/2);
                    g.balance = 0;
                    return;
                }
            }
            g.turn = player;
            g.time_limit = block.timestamp + (450); // around 7 * 1/2 minutes
        }
    }
    
    function claim_reward(address host) returns (bool retVal)
    {
        Game g = games[host];
        
        if(g.opposition != 0 
        && g.balance > 0 
        && block.timestamp > g.time_limit)
        {
            if(g.turn == 1)
                host.send(g.balance);
            else
                g.opposition.send(g.balance);
        }
    }
    
    function is_full(address host) returns (bool retVal)
    {
        Game g = games[host];
        uint count = 0;
        for(uint r; r < 3; r++)
            for(uint c; c < 3; c++)
                if(g.board.positions[r][c] > 0)
                    count++;
        if(count >= 9)
            return true;
    }
    
    function is_winner(address host, uint player) returns (bool retVal)
    {
        Game g = games[host];
        for(uint r; r < 3; r++)
            if(g.board.positions[r][0] == player
            && g.board.positions[r][1] == player
            && g.board.positions[r][2] == player)
                return true;
                
        for(uint c; c < 3; c++)
            if(g.board.positions[0][c] == player
            && g.board.positions[1][c] == player
            && g.board.positions[2][c] == player)
                return true;
            
        if(g.board.positions[0][0] == player
        && g.board.positions[1][1] == player
        && g.board.positions[2][2] == player)
            return true;
            
        if(g.board.positions[0][2] == player
        && g.board.positions[1][1] == player
        && g.board.positions[2][0] == player)
            return true;
    }
    
    function clear(address host)
    {
        Game g = games[host];
        if(msg.sender == host && g.balance == 0)

        {
            g.turn = 1;
            g.opposition = 0;
            for (uint r = 0; r < 3; ++r)
                for (uint c = 0; c < 3; ++c)
                    g.board.positions[r][c] = 0;
        }
    }
}

