function mCheckUpdate_ECOGProcess(logstr, syncOpt)
    % Commit your work and check update for current project.
    % Putting it in your startup.m is RECOMMENDED.
    % Use it for other projects, rename and put it in the root path of the project.
    %
    % logstr: log information, in string or char
    % syncOpt: if set true, your local change will be pushed to remote. (default: false)

    narginchk(0, 2);

    if nargin < 1
        logstr = [];
    end

    if nargin < 2
        syncOpt = false;
    end
    
    syncRepositories(logstr, "RepositoryPaths", fileparts(mfilename("fullpath")), "SyncOption", syncOpt);
    return;
end