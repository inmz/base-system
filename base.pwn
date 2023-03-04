/*

        Base system by kaufman
    
        - 

*/

#define SSCANF_NO_NICE_FEATURES

#include <a_samp>
#include <a_mysql>                      // https://github.com/pBlueG/SA-MP-MySQL/releases/tag/R41-4
#include <sscanf2>                      // https://github.com/Y-Less/sscanf/releases/tag/v2.13.8
#include <YSI/YSI_Data/y_iterate>       // https://github.com/pawn-lang/YSI-Includes/releases/tag/v5.06.1932
#include <YSI/YSI_Visual/y_commands>    // https://github.com/pawn-lang/YSI-Includes/releases/tag/v5.06.1932

#define MAX_BASES           (50)

enum e_bases
{
    name[32],
    att_pos[24],
    def_pos[24],
    cp_pos[24]
};
new base_data[MAX_BASES][e_bases];

new MySQL: m_handle;

new Iterator: Bases<MAX_BASES>;

main() { }

public OnGameModeInit()
{
    new MySQLOpt: option_id = mysql_init_options();
    mysql_set_option(option_id, AUTO_RECONNECT, true);

    m_handle = mysql_connect("localhost", "root", "", "sa-mp", option_id);

    if (m_handle == MYSQL_INVALID_HANDLE || mysql_errno(m_handle) != 0)
    {
        print("MySQL connection failed.");
        SendRconCommand("exit");
        return 1;
    }

    print("MySQL connection is successful.");

    mysql_tquery(m_handle, "SELECT * FROM `bases`", "LoadBases", "");

    return 1;
}

public OnGameModeExit()
{
    mysql_close(m_handle);

    return 1;
}

forward LoadBases();
public LoadBases()
{
    new rows = cache_num_rows();
    if(rows)
    {
        new loaded;
        while(loaded < rows)
        {
            new base_id = Iter_Free(Bases);

            cache_get_value_name(loaded, "name", base_data[base_id][name], 32);
            cache_get_value_name(loaded, "attpos", base_data[base_id][att_pos], 60);
            cache_get_value_name(loaded, "defpos", base_data[base_id][def_pos], 60);
            cache_get_value_name(loaded, "cppos", base_data[base_id][cp_pos], 60);

            Iter_Add(Bases, base_id);

            loaded++;
        }

        printf(" [Base] Loaded %d bases.", loaded);
    }

    return 1;
}

CMD:base(playerid, params[])
{
    new input[32], args[64], command_id, base_id = Iter_Free(Bases);

    if (sscanf(params, "s[32]S()[64]", input, args))
        return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [create, name, att, def, cp, delete]");

    if(!strcmp(input, "create", false)) command_id = 1;
    else if (!strcmp(input, "name", false)) command_id = 2;
    else if (!strcmp(input, "att", false)) command_id = 3;
    else if (!strcmp(input, "def", false)) command_id = 4;
    else if (!strcmp(input, "cp", false)) command_id = 5;
    else if (!strcmp(input, "delete", false)) command_id = 6;
	else return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [create, name, att, def, cp, delete]");

    switch (command_id)
    {
        case 1:
        {
            if (base_id == INVALID_ITERATOR_SLOT)
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}no more bases can be created.");

            Iter_Add(Bases, base_id);

            new query[110 + 4];
            mysql_format(m_handle, query, sizeof query, "INSERT INTO `bases` (`id`, `attpos`, `defpos`, `cppos`, `name`) VALUES ('%d', '0', '0', '0', 'Null')", base_id);
            mysql_tquery(m_handle, query);
        
            new string[58 + 4];
            format(string, sizeof string, "(base) {F9F9F9}A base has been created. (ID: %d)", base_id);
            SendClientMessage(playerid, 0x89C251FF, string);
        }

        case 2:
        {
            new base_name[32];

            if (sscanf(args, "ds[32]", base_id, base_name))
                return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [name] [id] [new name]");

            if (!Iter_Contains(Bases, base_id))
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}A base with this ID could not be found.");

            base_data[base_id][name] = base_name;

            new query[60 + 32 + 4];
            mysql_format(m_handle, query, sizeof query, "UPDATE `bases` SET `name` = '%s' WHERE `id` = '%d'", base_data[base_id][name], base_id);
            mysql_tquery(m_handle, query);
        
            new string[65 + 4];
            format(string, sizeof string, "(base) {F9F9F9}The base with ID %d has been renamed %s.", base_id, base_data[base_id][name]);
            SendClientMessage(playerid, 0x89C251FF, string);
        }
    
        case 3:
        {
            if (sscanf(args, "d", base_id))
                return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [att] [id]");

            if (!Iter_Contains(Bases, base_id))
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}A base with this ID could not be found.");

            new merge_pos[24], Float: p[3];
            GetPlayerPos(playerid, p[0], p[1], p[2]);
            format(merge_pos, sizeof merge_pos, "%.1f,%.1f,%.1f", p[0], p[1], p[2]);

            base_data[base_id][att_pos] = merge_pos;

            new query[62 + 32 + 4];
            mysql_format(m_handle, query, sizeof query, "UPDATE `bases` SET `attpos` = '%s' WHERE `id` = '%d'", base_data[base_id][att_pos], base_id);
            mysql_tquery(m_handle, query);
        
            new string[82 + 4];
            format(string, sizeof string, "(base) {F9F9F9}Attacker coordinates of base with ID %d has been updated.", base_id);
            SendClientMessage(playerid, 0x89C251FF, string);
        }

        case 4:
        {
            if (sscanf(args, "d", base_id))
                return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [def] [id]");

            if (!Iter_Contains(Bases, base_id))
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}A base with this ID could not be found.");

            new merge_pos[24], Float: p[3];
            GetPlayerPos(playerid, p[0], p[1], p[2]);
            format(merge_pos, sizeof merge_pos, "%.1f,%.1f,%.1f", p[0], p[1], p[2]);

            base_data[base_id][def_pos] = merge_pos;

            new query[62 + 32 + 4];
            mysql_format(m_handle, query, sizeof query, "UPDATE `bases` SET `defpos` = '%s' WHERE `id` = '%d'", base_data[base_id][def_pos], base_id);
            mysql_tquery(m_handle, query);
        
            new string[82 + 4];
            format(string, sizeof string, "(base) {F9F9F9}Defender coordinates of base with ID %d has been updated.", base_id);
            SendClientMessage(playerid, 0x89C251FF, string);
        }

        case 5:
        {
            if (sscanf(args, "d", base_id))
                return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [cp] [id]");

            if (!Iter_Contains(Bases, base_id))
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}A base with this ID could not be found.");

            new merge_pos[24], Float: p[3];
            GetPlayerPos(playerid, p[0], p[1], p[2]);
            format(merge_pos, sizeof merge_pos, "%.1f,%.1f,%.1f", p[0], p[1], p[2]);

            base_data[base_id][cp_pos] = merge_pos;

            new query[61 + 32 + 4];
            mysql_format(m_handle, query, sizeof query, "UPDATE `bases` SET `cppos` = '%s' WHERE `id` = '%d'", base_data[base_id][cp_pos], base_id);
            mysql_tquery(m_handle, query);
        
            new string[84 + 4];
            format(string, sizeof string, "(base) {F9F9F9}Checkpoint coordinates of base with ID %d has been updated.", base_id);
            SendClientMessage(playerid, 0x89C251FF, string);
        }

        case 6:
        {
            if (sscanf(args, "d", base_id))
                return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/base [delete] [id]");

            if (!Iter_Contains(Bases, base_id))
                return SendClientMessage(playerid, 0xD3978FFF, "(error) {F9F9F9}A base with this ID could not be found.");

            Iter_Remove(Bases, base_id);

            new query[46 + 4];
            mysql_format(m_handle, query, sizeof query, "DELETE FROM `bases` WHERE `id`= '%d'", base_id);
            mysql_tquery(m_handle, query);

            new string[53 + 4];
            format(string, sizeof string, "(base) {F9F9F9}Base with %d ID deleted from database.", base_id);
            SendClientMessage(playerid, 0x89C251FF, string);
        }
    }

    return 1;
}

CMD:startbase(playerid, params[])
{
    new id;

    if (sscanf(params, "d", id))
        return SendClientMessage(playerid, 0x92B4ECFF, "(usage) {F9F9F9}/startbase [id]");

    new Float: pos[3];

    sscanf(base_data[id][def_pos], "p<,>fff", pos[0], pos[1], pos[2]);
    SetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    return 1;
}