<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	//세션 유효성 검사(로그인 유무)
	if(session.getAttribute("loginMemberId") != null) { // 로그인이 되어있다면
		response.sendRedirect(request.getContextPath()+"/boardList.jsp"); // 메인페이지로
		return;
	}
%>    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>login</title>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<h1>로그인</h1>
	<br>
	<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post">
		<table class="table table-hover">
			<tr>
				<th>아이디</th>
				<td>
					<input type="text" name="memberId" required="required">
				</td>
			</tr>
			<tr>
				<td>패스워드</td>
				<td>
					<input type="password" name="memberPw" required="required">
				</td>
			</tr>
		</table>
		<input type="submit" class="btn btn-outline-secondary" value="로그인">
		<a type="button" class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/boardList.jsp">목록으로</a>
	</form>
</body>
</html>